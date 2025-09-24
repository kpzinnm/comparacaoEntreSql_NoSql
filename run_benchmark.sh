#!/bin/bash


set -e  # Sai imediatamente em caso de erro

# Configurações
RESULTS_DIR="results_teste_carga"
DATASETS_DIR="datasets"
LOG_FILE="benchmark_$(date +%Y%m%d_%H%M%S).log"

mkdir -p $RESULTS_DIR

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

exec_psql() {
    local sql=$1
    docker exec -i postgres-db psql -U teste -d testedb -c "$sql" 2>> $LOG_FILE || true
}

exec_psql_file() {
    local file=$1
    docker exec -i postgres-db psql -U teste -d testedb < "$file" 2>/dev/null || true
}

table_exists() {
    local table_name=$1
    local result=$(exec_psql "SELECT to_regclass('$table_name');" | grep -v "to_regclass" | grep -v "row" | tr -d ' \n')
    [[ "$result" != "(0rows)" && "$result" != "" ]]
}

start_resource_monitoring() {
    local db_type=$1
    local scenario=$2
    log "Iniciando monitoramento de recursos para $db_type ($scenario)..."
    
    if [ "$db_type" == "postgres" ]; then
        docker stats postgres-db --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" > $RESULTS_DIR/postgres_stats_${scenario}.log &
        MONITOR_PID=$!
    else
        docker stats mongo-db --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" > $RESULTS_DIR/mongo_stats_${scenario}.log &
        MONITOR_PID=$!
    fi
}

stop_resource_monitoring() {
    if [ ! -z "$MONITOR_PID" ]; then
        sleep 2
        kill $MONITOR_PID 2>/dev/null || true
        MONITOR_PID="" 
        log "Monitoramento de recursos finalizado."
    fi
}

create_missing_tables() {
    log "Verificando e criando tabelas faltantes..."
    
    for csv_file in $DATASETS_DIR/*.csv; do
        if [ -f "$csv_file" ]; then
            table_name=$(basename "$csv_file" .csv)
            
            if ! table_exists "$table_name"; then
                log "Criando tabela: $table_name"
                
                header=$(head -1 "$csv_file")
                
                columns=$(echo "$header" | sed 's/,/ TEXT,/g' | sed 's/"//g')
                create_sql="CREATE TABLE IF NOT EXISTS $table_name ($columns TEXT);"
                
                exec_psql "$create_sql"
                
                first_column=$(echo "$header" | cut -d',' -f1 | sed 's/"//g')
                exec_psql "CREATE INDEX IF NOT EXISTS idx_${table_name}_${first_column} ON $table_name($first_column);"
            else
                log "Tabela $table_name já existe."
            fi
        fi
    done
}

# Preparação dos dados
prepare_databases() {
    log "=== PREPARAÇÃO DOS BANCOS DE DADOS ==="
    
    if [ -f "postgres/init/01-init.sql" ]; then
        log "Executando script de schema do PostgreSQL..."
        exec_psql_file "postgres/init/01-init.sql"
    else
        log "AVISO: Schema não encontrado. Criando tabelas dinamicamente..."
        create_missing_tables
    fi
    
    create_missing_tables
    
    # PostgreSQL: Carregar dados CSV
    log "Carregando dados no PostgreSQL..."
    for csv_file in $DATASETS_DIR/*.csv; do
        if [ -f "$csv_file" ]; then
            table_name=$(basename "$csv_file" .csv)
            
            if table_exists "$table_name"; then
                log "Carregando tabela: $table_name"
                
                docker cp "$csv_file" postgres-db:/tmp/$(basename "$csv_file")
                
                exec_psql "TRUNCATE TABLE $table_name;"
                exec_psql "COPY $table_name FROM '/tmp/$(basename "$csv_file")' WITH CSV HEADER;"
                
                docker exec postgres-db rm -f /tmp/$(basename "$csv_file")
                
                count=$(exec_psql "SELECT COUNT(*) FROM $table_name;" | grep -v "count" | grep -v "row" | tr -d ' \n')
                log "Tabela $table_name carregada com $count registros"
            else
                log "ERRO: Tabela $table_name não existe e não pôde ser criada."
            fi
        fi
    done
    
    # MongoDB: Carregar dados JSON
    log "Carregando dados no MongoDB..."
    for json_file in $DATASETS_DIR/mongo/*.json; do
        if [ -f "$json_file" ]; then
            collection_name=$(basename "$json_file" .json)
            log "Carregando coleção: $collection_name"
            
            docker exec mongo-db mongosh -u teste -p teste --authenticationDatabase admin \
                --eval "db.getSiblingDB('olist').$collection_name.countDocuments()" --quiet > /dev/null 2>&1
            
            if [ $? -eq 0 ]; then
                docker exec mongo-db mongosh -u teste -p teste --authenticationDatabase admin \
                    --eval "db.getSiblingDB('olist').$collection_name.deleteMany({})" --quiet
            fi
            
            docker exec -i mongo-db mongoimport -u teste -p teste --authenticationDatabase admin \
                --db olist --collection $collection_name --jsonArray --file /dev/stdin < "$json_file"
        fi
    done
    
    log "Preparação concluída!"
}

wait_for_containers() {
    log "Aguardando containers ficarem prontos..."
    
    until docker exec postgres-db pg_isready -U teste -d testedb > /dev/null 2>&1; do
        sleep 2
    done
    
    until docker exec mongo-db mongosh -u teste -p teste --authenticationDatabase admin --eval "db.adminCommand('ping')" --quiet > /dev/null 2>&1; do
        sleep 2
    done
    
    log "Containers prontos!"
}

# Benchmark PostgreSQL com Sysbench
run_postgres_benchmarks() {
    log "=== INICIANDO BENCHMARKS POSTGRESQL ==="
    
    log "Preparando ambiente Sysbench..."
    docker exec sysbench-runner /app/scripts/carga/prepare_sysbench.sh
    
    log "Executando benchmarks Sysbench..."
    docker exec sysbench-runner /app/scripts/carga/run_benchmarks.sh > $RESULTS_DIR/sysbench_all.log 2>&1
    
    awk '/=== CENÁRIO READ-HEAVY ===/,/=== CENÁRIO WRITE-HEAVY ===/' $RESULTS_DIR/sysbench_all.log > $RESULTS_DIR/postgres_read_heavy.log
    awk '/=== CENÁRIO WRITE-HEAVY ===/,/=== CENÁRIO BALANCEADO ===/' $RESULTS_DIR/sysbench_all.log > $RESULTS_DIR/postgres_write_heavy.log
    awk '/=== CENÁRIO BALANCEADO ===/,/Benchmarks Sysbench concluídos!/' $RESULTS_DIR/sysbench_all.log > $RESULTS_DIR/postgres_balanced.log
    
    log "Benchmarks PostgreSQL concluídos!"
}

# Benchmark MongoDB com YCSB
run_mongo_benchmarks() {
    log "=== INICIANDO BENCHMARKS MONGODB ==="
    
    local YCSB_EXEC="docker exec -w /opt/YCSB ycsb-runner ./bin/ycsb"

    log "Carregando dados com YCSB (workload a)..."
    $YCSB_EXEC load mongodb -s \
        -P workloads/carga/workload_load \
        -p mongodb.url="mongodb://teste:teste@mongo-db:27017/ycsb?authSource=admin" \
        > $RESULTS_DIR/mongo_load.log 2>&1

    # Cenário 1: Read-Heavy 
    log "Executando cenário Read-Heavy no MongoDB (workload c)..."
    start_resource_monitoring "mongo" "read_heavy"
    $YCSB_EXEC run mongodb -s \
        -P workloads/carga/workload_read_heavy \
        -p mongodb.url="mongodb://teste:teste@mongo-db:27017/ycsb?authSource=admin" \
        > $RESULTS_DIR/mongo_read_heavy.log 2>&1
    stop_resource_monitoring

    # Cenário 2: Write-Heavy 
    log "Executando cenário Write-Heavy no MongoDB (workload a - 50/50)..."
    start_resource_monitoring "mongo" "write_heavy"
    $YCSB_EXEC run mongodb -s \
        -P workloads/carga/workload_write_heavy \
        -p mongodb.url="mongodb://teste:teste@mongo-db:27017/ycsb?authSource=admin" \
        > $RESULTS_DIR/mongo_write_heavy.log 2>&1
    stop_resource_monitoring

    # Cenário 3: Balanceado 
    log "Executando cenário Balanceado no MongoDB (workload a)..."
    start_resource_monitoring "mongo" "balanced"
    $YCSB_EXEC run mongodb -s \
        -P workloads/carga/workload_balanced \
        -p mongodb.url="mongodb://teste:teste@mongo-db:27017/ycsb?authSource=admin" \
        > $RESULTS_DIR/mongo_balanced.log 2>&1
    stop_resource_monitoring

    log "Benchmarks MongoDB concluídos!"
}

main() {
    log "Iniciando benchmark comparativo PostgreSQL vs MongoDB"
    
    if ! docker ps | grep -q "postgres-db"; then
        log "ERRO: Container postgres-db não está rodando!"
        exit 1
    fi
    
    if ! docker ps | grep -q "mongo-db"; then
        log "ERRO: Container mongo-db não está rodando!"
        exit 1
    fi
    
    wait_for_containers
    
    prepare_databases
    #run_postgres_benchmarks
    run_mongo_benchmarks
    
    log "=== BENCHMARK CONCLUÍDO ==="
    log "Resultados salvos em: $RESULTS_DIR/"
    log "Log detalhado: $LOG_FILE"
    
    generate_summary
}

# Gerar relatório de resumo
generate_summary() {
    cat > $RESULTS_DIR/generate_summary.sh << 'EOF'
#!/bin/bash
echo "=== RESUMO DOS RESULTADOS ==="
echo ""
echo "PostgreSQL Read-Heavy:"
grep "transactions:" results/postgres_read_heavy.log | tail -1
grep "queries:" results/postgres_read_heavy.log | tail -1
echo ""
echo "PostgreSQL Write-Heavy:"
grep "transactions:" results/postgres_write_heavy.log | tail -1
grep "queries:" results/postgres_write_heavy.log | tail -1
echo ""
echo "PostgreSQL Balanced:"
grep "transactions:" results/postgres_balanced.log | tail -1
grep "queries:" results/postgres_balanced.log | tail -1
echo ""
echo "MongoDB Read-Heavy:"
grep "\[OVERALL\], Throughput" results/mongo_read_heavy.log
grep "\[READ\], AverageLatency" results/mongo_read_heavy.log
echo ""
echo "MongoDB Write-Heavy:"
grep "\[OVERALL\], Throughput" results/mongo_write_heavy.log
grep "\[UPDATE\], AverageLatency" results/mongo_write_heavy.log
echo ""
echo "MongoDB Balanced:"
grep "\[OVERALL\], Throughput" results/mongo_balanced.log
grep "\[READ\], AverageLatency" results/mongo_balanced.log
grep "\[UPDATE\], AverageLatency" results/mongo_balanced.log
EOF
    chmod +x $RESULTS_DIR/generate_summary.sh
    
    log "Execute './results/generate_summary.sh' para ver um resumo dos resultados"
}

main "$@"