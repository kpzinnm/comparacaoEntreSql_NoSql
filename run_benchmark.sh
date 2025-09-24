#!/bin/bash

set -e

RESULTS_DIR="results_teste_carga"
LOG_FILE="benchmark_$(date +%Y%m%d_%H%M%S).log"
mkdir -p $RESULTS_DIR

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
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

run_postgres_benchmark() {
    log "=== INICIANDO BENCHMARK POSTGRESQL ==="
    docker exec sysbench-runner sysbench /app/scripts/volume/custom_benchmark.lua \
        --pgsql-host=postgres-db --pgsql-user=teste --pgsql-password=teste --pgsql-db=testedb \
        run > $RESULTS_DIR/sysbench_all.log 2>&1
    log "Benchmarks PostgreSQL concluídos!"
}

run_mongo_queries() {
    log "=== EXECUTANDO CONSULTAS MONGO ==="
    bash ycsb/scripts/volume/mongo_queries.sh
    log "Consultas MongoDB concluídas!"
}

main() {
    log "Iniciando benchmark comparativo PostgreSQL vs MongoDB"

    # Verifica containers
    if ! docker ps | grep -q "postgres-db"; then
        log "ERRO: Container postgres-db não está rodando!"
        exit 1
    fi
    if ! docker ps | grep -q "mongo-db"; then
        log "ERRO: Container mongo-db não está rodando!"
        exit 1
    fi

    wait_for_containers

    # PostgreSQL
    run_postgres_benchmark

    # MongoDB
    run_mongo_queries

    log "=== BENCHMARK CONCLUÍDO ==="
    log "Resultados salvos em: $RESULTS_DIR/"
    log "Log detalhado: $LOG_FILE"
}

main "$@"
