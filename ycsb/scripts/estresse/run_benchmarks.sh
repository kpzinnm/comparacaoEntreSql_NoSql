#!/bin/bash

# Script de Benchmark MongoDB com YCSB - Teste de Estresse
# Autor: DevOps Senior

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Configurações
DB_HOST=${DB_HOST:-mongo-db}
DB_PORT=${DB_PORT:-27017}
DB_USER=${DB_USER:-teste}
DB_PASSWORD=${DB_PASSWORD:-teste}
DB_NAME=${DB_NAME:-olist}

log "Iniciando benchmarks MongoDB com diferentes níveis de estresse..."

# NÍVEL 1: Estresse Moderado (50 threads)
log "=== NÍVEL 1: ESTRESSE MODERADO (50 threads) ==="
log "Carregando dados..."
docker exec -w /opt/YCSB ycsb-runner ./bin/ycsb load mongodb -s \
    -P workloads/estresse/workload_moderate \
    -p mongodb.url="mongodb://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME?authSource=admin" \
    > results_teste_estresse/mongo_load_moderate.log 2>&1

log "Executando benchmark moderado..."
docker exec -w /opt/YCSB ycsb-runner ./bin/ycsb run mongodb -s \
    -P workloads/estresse/workload_moderate \
    -p mongodb.url="mongodb://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME?authSource=admin" \
    > results_teste_estresse/mongo_moderate.log 2>&1

# NÍVEL 2: Estresse Alto (100 threads)
log "=== NÍVEL 2: ESTRESSE ALTO (100 threads) ==="
log "Carregando dados..."
docker exec -w /opt/YCSB ycsb-runner ./bin/ycsb load mongodb -s \
    -P workloads/estresse/workload_high \
    -p mongodb.url="mongodb://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME?authSource=admin" \
    > results_teste_estresse/mongo_load_high.log 2>&1

log "Executando benchmark alto..."
docker exec -w /opt/YCSB ycsb-runner ./bin/ycsb run mongodb -s \
    -P workloads/estresse/workload_high \
    -p mongodb.url="mongodb://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME?authSource=admin" \
    > results_teste_estresse/mongo_high.log 2>&1

# NÍVEL 3: Estresse Extremo (200 threads)
log "=== NÍVEL 3: ESTRESSE EXTREMO (200 threads) ==="
log "Carregando dados..."
docker exec -w /opt/YCSB ycsb-runner ./bin/ycsb load mongodb -s \
    -P workloads/estresse/workload_extreme \
    -p mongodb.url="mongodb://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME?authSource=admin" \
    > results_teste_estresse/mongo_load_extreme.log 2>&1

log "Executando benchmark extremo..."
docker exec -w /opt/YCSB ycsb-runner ./bin/ycsb run mongodb -s \
    -P workloads/estresse/workload_extreme \
    -p mongodb.url="mongodb://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME?authSource=admin" \
    > results_teste_estresse/mongo_extreme.log 2>&1

log "Benchmarks MongoDB concluídos!"
