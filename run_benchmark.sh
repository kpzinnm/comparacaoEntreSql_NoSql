#!/bin/bash

# Script de Benchmark PostgreSQL vs MongoDB
# Autor: DevOps Senior
# Data: $(date +%Y-%m-%d)

set -e  # Sai imediatamente em caso de erro

# Configurações
RESULTS_DIR="results_teste_consultas"
DATASETS_DIR="datasets"
LOG_FILE="benchmark_$(date +%Y%m%d_%H%M%S).log"

# Cria diretório de resultados
mkdir -p $RESULTS_DIR

# Função para log
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Função para executar comando no PostgreSQL
exec_psql() {
    local sql=$1
    docker exec -i postgres-db psql -U teste -d testedb -c "$sql" 2>> $LOG_FILE || true
}

# Função para executar script no PostgreSQL
exec_psql_file() {
    local file=$1
    docker exec -i postgres-db psql -U teste -d testedb < "$file" 2>/dev/null || true
}

# Função para verificar se uma tabela existe
table_exists() {
    local table_name=$1
    local result=$(exec_psql "SELECT to_regclass('$table_name');" | grep -v "to_regclass" | grep -v "row" | tr -d ' \n')
    [[ "$result" != "(0rows)" && "$result" != "" ]]
}

# Função para monitorar recursos
start_resource_monitoring() {
    local db_type=$1
    local scenario=$2
    log "Iniciando monitoramento de recursos para $db_type ($scenario)..."
    
    # CORREÇÃO: Removido --no-stream para monitoramento contínuo
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
        # Dá um tempo para o processo docker stats coletar os últimos dados
        sleep 2
        kill $MONITOR_PID 2>/dev/null || true
        MONITOR_PID="" # Limpa a variável
        log "Monitoramento de recursos finalizado."
    fi
}

# Criar tabelas dinamicamente se necessário
create_missing_tables() {
    log "Verificando e criando tabelas faltantes..."
    
    for csv_file in $DATASETS_DIR/*.csv; do
        if [ -f "$csv_file" ]; then
            table_name=$(basename "$csv_file" .csv)
            
            if ! table_exists "$table_name"; then
                log "Criando tabela: $table_name"
                
                # Obter cabeçalho do CSV
                header=$(head -1 "$csv_file")
                
                # Criar comando CREATE TABLE dinâmico
                columns=$(echo "$header" | sed 's/,/ TEXT,/g' | sed 's/"//g')
                create_sql="CREATE TABLE IF NOT EXISTS $table_name ($columns TEXT);"
                
                # Executar criação da tabela
                exec_psql "$create_sql"
                
                # Criar índice na primeira coluna (assumindo que é uma chave)
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
    
    # PostgreSQL: Executar script de schema se existir
    if [ -f "postgres/init/01-init.sql" ]; then
        log "Executando script de schema do PostgreSQL..."
        exec_psql_file "postgres/init/01-init.sql"
    else
        log "AVISO: Schema não encontrado. Criando tabelas dinamicamente..."
        create_missing_tables
    fi
    
    # Verificar novamente e criar tabelas faltantes
    create_missing_tables
    
    # PostgreSQL: Carregar dados CSV
    log "Carregando dados no PostgreSQL..."
    for csv_file in $DATASETS_DIR/*.csv; do
        if [ -f "$csv_file" ]; then
            table_name=$(basename "$csv_file" .csv)
            
            if table_exists "$table_name"; then
                log "Carregando tabela: $table_name"
                
                # Copiar arquivo para o container temporariamente
                docker cp "$csv_file" postgres-db:/tmp/$(basename "$csv_file")
                
                # Carregar dados usando COPY
                exec_psql "TRUNCATE TABLE $table_name;"
                exec_psql "COPY $table_name FROM '/tmp/$(basename "$csv_file")' WITH CSV HEADER;"
                
                # Limpar arquivo temporário
                docker exec postgres-db rm -f /tmp/$(basename "$csv_file")
                
                # Contar registros carregados
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
            
            # Verificar se a coleção já tem dados e limpar
            docker exec mongo-db mongosh -u teste -p teste --authenticationDatabase admin \
                --eval "db.getSiblingDB('olist').$collection_name.countDocuments()" --quiet > /dev/null 2>&1
            
            if [ $? -eq 0 ]; then
                docker exec mongo-db mongosh -u teste -p teste --authenticationDatabase admin \
                    --eval "db.getSiblingDB('olist').$collection_name.deleteMany({})" --quiet
            fi
            
            # Carregar dados (COM A CORREÇÃO --jsonArray)
            docker exec -i mongo-db mongoimport -u teste -p teste --authenticationDatabase admin \
                --db olist --collection $collection_name --jsonArray --file /dev/stdin < "$json_file"
        fi
    done
    
    log "Preparação concluída!"
}

# Função para verificar se os containers estão prontos
wait_for_containers() {
    log "Aguardando containers ficarem prontos..."
    
    # Aguardar PostgreSQL
    until docker exec postgres-db pg_isready -U teste -d testedb > /dev/null 2>&1; do
        sleep 2
    done
    
    # Aguardar MongoDB
    until docker exec mongo-db mongosh -u teste -p teste --authenticationDatabase admin --eval "db.adminCommand('ping')" --quiet > /dev/null 2>&1; do
        sleep 2
    done
    
    log "Containers prontos!"
}

# Benchmark PostgreSQL com Sysbench
run_postgres_benchmarks() {
    log "=== INICIANDO BENCHMARKS POSTGRESQL ==="
    
    # Preparar ambiente sysbench
    log "Preparando ambiente Sysbench..."
    docker exec sysbench-runner /app/scripts/desempenho_consultas/prepare_sysbench.sh
    
    # Executar benchmarks usando o script interno
    log "Executando benchmarks Sysbench..."
    docker exec sysbench-runner /app/scripts/desempenho_consultas/run_benchmarks.sh > $RESULTS_DIR/sysbench_all.log 2>&1
    
    # Separar logs por cenário
    awk '/=== CENÁRIO READ SIMPLE ===/,/=== CENÁRIO READ RANGE ===/' $RESULTS_DIR/sysbench_all.log > $RESULTS_DIR/postgres_read_simple.log
    awk '/=== CENÁRIO READ RANGE ===/,/=== CENÁRIO READ JOIN + AGG ===/' $RESULTS_DIR/sysbench_all.log > $RESULTS_DIR/postgres_read_range.log
    awk '/=== CENÁRIO READ JOIN + AGG ===/,/Benchmarks Sysbench concluídos!/' $RESULTS_DIR/sysbench_all.log > $RESULTS_DIR/postgres_read_join_agg.log
    
    log "Benchmarks PostgreSQL concluídos!"
}

# Benchmark MongoDB com YCSB
run_mongo_benchmarks() {
    log "=== INICIANDO BENCHMARKS MONGODB ==="
    
    # CORREÇÃO: Adicionado -w /opt/YCSB para garantir a execução no diretório correto
    local YCSB_EXEC="docker exec -w /opt/YCSB ycsb-runner ./bin/ycsb"

    # Carregar dados iniciais com YCSB
    log "Carregando dados com YCSB"
    $YCSB_EXEC load mongodb -s \
        -P workloads/desempenho_consultas/workload_load \
        -p mongodb.url="mongodb://teste:teste@mongo-db:27017/ycsb?authSource=admin" \
        > $RESULTS_DIR/mongo_load.log 2>&1

    # Cenário 1: Read Simple
    log "Executando cenário Read Simple no MongoDB..."
    start_resource_monitoring "mongo" "read_simple"
    $YCSB_EXEC run mongodb -s \
        -P workloads/desempenho_consultas/workload_read_simple \
        -p mongodb.url="mongodb://teste:teste@mongo-db:27017/ycsb?authSource=admin" \
        > $RESULTS_DIR/mongo_read_simple.log 2>&1
    stop_resource_monitoring

    # Cenário 2: Read Range
    log "Executando cenário Read Range no MongoDB..."
    start_resource_monitoring "mongo" "read_range"
    $YCSB_EXEC run mongodb -s \
        -P workloads/desempenho_consultas/workload_read_range \
        -p mongodb.url="mongodb://teste:teste@mongo-db:27017/ycsb?authSource=admin" \
        > $RESULTS_DIR/mongo_read_range.log 2>&1
    stop_resource_monitoring

    # Cenário 3: Read Join Agg
    log "Executando cenário Read Join Agg no MongoDB"
    start_resource_monitoring "mongo" "read_join_agg"
    $YCSB_EXEC run mongodb -s \
        -P workloads/desempenho_consultas/workload_read_join_agg \
        -p mongodb.url="mongodb://teste:teste@mongo-db:27017/ycsb?authSource=admin" \
        > $RESULTS_DIR/mongo_read_join_agg.log 2>&1
    stop_resource_monitoring

    log "Benchmarks MongoDB concluídos!"
}

# Função principal
main() {
    log "Iniciando benchmark comparativo PostgreSQL vs MongoDB"
    
    # Verificar se os containers estão rodando
    if ! docker ps | grep -q "postgres-db"; then
        log "ERRO: Container postgres-db não está rodando!"
        exit 1
    fi
    
    if ! docker ps | grep -q "mongo-db"; then
        log "ERRO: Container mongo-db não está rodando!"
        exit 1
    fi
    
    # Aguardar containers ficarem prontos
    wait_for_containers
    
    # Executar sequência de benchmarks
    #prepare_databases
    run_postgres_benchmarks
    run_mongo_benchmarks
    
    log "=== BENCHMARK CONCLUÍDO ==="
    log "Resultados salvos em: $RESULTS_DIR/"
    log "Log detalhado: $LOG_FILE"
    
    log "Execute './generate_summary.sh' para ver um resumo dos resultados"
}

# Executar função principal
main "$@"