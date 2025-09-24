#!/bin/bash

# Script de Benchmark PostgreSQL vs MongoDB
# Autor: DevOps Senior
# Data: $(date +%Y-%m-%d)

set -e  # Sai imediatamente em caso de erro

# Configurações
RESULTS_DIR="results_teste_estresse"
DATASETS_DIR="datasets"
LOG_FILE="benchmark_$(date +%Y%m%d_%H%M%S).log"

# Cria diretório de resultados
mkdir -p $RESULTS_DIR

# Função para log
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Função para executar comando no PostgreSQL
exec_psql() {
    local sql=$1
    docker exec -i postgres-db psql -U teste -d testedb -c "$sql" 2>>"$LOG_FILE" || true
}

# Função para executar script no PostgreSQL
exec_psql_file() {
    local file=$1
    docker exec -i postgres-db psql -U teste -d testedb < "$file" 2>/dev/null || true
}

# Função para verificar se uma tabela existe
table_exists() {
    local table_name=$1
    local result
    result=$(exec_psql "SELECT to_regclass('$table_name');" | grep -v "to_regclass" | grep -v "row" | tr -d ' \n')
    [[ "$result" != "(0rows)" && "$result" != "" ]]
}

# Função para monitorar recursos
start_resource_monitoring() {
    local db_type=$1
    local scenario=$2
    log "Iniciando monitoramento de recursos para $db_type ($scenario)..."

    if [ "$db_type" == "postgres" ]; then
        docker stats postgres-db --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" > "$RESULTS_DIR/postgres_stats_${scenario}.log" &
        MONITOR_PID=$!
    else
        docker stats mongo-db --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" > "$RESULTS_DIR/mongo_stats_${scenario}.log" &
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

# Função para verificar se os containers estão prontos
wait_for_containers() {
    log "Aguardando containers ficarem prontos..."

    # Aguardar PostgreSQL
    until docker exec postgres-db pg_isready -U teste -d testedb > /dev/null 2>&1; do
        sleep 2
    done

    # Aguardar MongoDB
    until docker exec mongo-db mongosh -u teste -p teste --authenticationDatabase admin \
          --eval "db.adminCommand('ping')" --quiet > /dev/null 2>&1; do
        sleep 2
    done

    log "Containers prontos!"
}

# Benchmark PostgreSQL com Sysbench
run_postgres_benchmarks() {
    log "=== INICIANDO BENCHMARKS POSTGRESQL ==="

    # Preparar ambiente sysbench
    log "Preparando ambiente Sysbench..."
    docker exec sysbench-runner bash -c '/app/scripts/prepare_sysbench.sh' || { log "ERRO: falha ao preparar Sysbench"; exit 1; }

    # Executar benchmarks usando o script interno
    log "Executando benchmarks Sysbench..."
    docker exec sysbench-runner bash -c '/app/scripts/estresse/run_benchmarks.sh' > "$RESULTS_DIR/sysbench_all.log" 2>&1

    # Separar logs por cenário
    awk '/=== CENÁRIO READ-HEAVY ===/,/=== CENÁRIO WRITE-HEAVY ===/' "$RESULTS_DIR/sysbench_all.log" > "$RESULTS_DIR/postgres_read_heavy.log"
    awk '/=== CENÁRIO WRITE-HEAVY ===/,/=== CENÁRIO BALANCEADO ===/' "$RESULTS_DIR/sysbench_all.log" > "$RESULTS_DIR/postgres_write_heavy.log"
    awk '/=== CENÁRIO BALANCEADO ===/,/Benchmarks Sysbench concluídos!/' "$RESULTS_DIR/sysbench_all.log" > "$RESULTS_DIR/postgres_balanced.log"

    log "Benchmarks PostgreSQL concluídos!"
}

# Benchmark MongoDB com YCSB
run_mongo_benchmarks() {
    log "=== INICIANDO BENCHMARKS MONGODB ==="
    
    # Executar benchmarks usando o script interno de estresse
    log "Executando benchmarks YCSB com diferentes níveis de estresse..."
    docker exec ycsb-runner bash -c '/app/scripts/estresse/run_benchmarks.sh' > "$RESULTS_DIR/mongo_all.log" 2>&1

    log "Benchmarks MongoDB concluídos!"
}

# Função principal
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

    # Executar benchmarks
    run_postgres_benchmarks
    run_mongo_benchmarks

    log "=== BENCHMARK CONCLUÍDO ==="
    log "Resultados salvos em: $RESULTS_DIR/"
    log "Log detalhado: $LOG_FILE"

    generate_summary
}

# Gerar relatório de resumo
generate_summary() {
    cat > "$RESULTS_DIR/generate_summary.sh" << 'EOF'
#!/bin/bash
echo "=== RESUMO DOS RESULTADOS ==="
echo ""
echo "PostgreSQL Read-Heavy:"
grep "transactions:" results_teste_estresse/postgres_read_heavy.log | tail -1
grep "queries:" results_teste_estresse/postgres_read_heavy.log | tail -1
echo ""
echo "PostgreSQL Write-Heavy:"
grep "transactions:" results_teste_estresse/postgres_write_heavy.log | tail -1
grep "queries:" results_teste_estresse/postgres_write_heavy.log | tail -1
echo ""
echo "PostgreSQL Balanced:"
grep "transactions:" results_teste_estresse/postgres_balanced.log | tail -1
grep "queries:" results_teste_estresse/postgres_balanced.log | tail -1
echo ""
echo "MongoDB Read-Heavy:"
grep "\[OVERALL\], Throughput" results_teste_estresse/mongo_read_heavy.log
grep "\[READ\], AverageLatency" results_teste_estresse/mongo_read_heavy.log
echo ""
echo "MongoDB Write-Heavy:"
grep "\[OVERALL\], Throughput" results_teste_estresse/mongo_write_heavy.log
grep "\[UPDATE\], AverageLatency" results_teste_estresse/mongo_write_heavy.log
echo ""
echo "MongoDB Balanced:"
grep "\[OVERALL\], Throughput" results_teste_estresse/mongo_balanced.log
grep "\[READ\], AverageLatency" results_teste_estresse/mongo_balanced.log
grep "\[UPDATE\], AverageLatency" results_teste_estresse/mongo_balanced.log
EOF
    chmod +x "$RESULTS_DIR/generate_summary.sh"
    log "Execute './$RESULTS_DIR/generate_summary.sh' para ver um resumo dos resultados"
}

main "$@"
