#!/bin/bash

# Script para executar benchmarks de consultas Sysbench

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

run_benchmark() {
    local scenario=$1
    local threads=$2
    local time=$3
    
    log "Executando cenário: $scenario"
    log "Threads: $threads, Duração: ${time}s"
    
    sysbench oltp_read_only \
        --db-driver=pgsql \
        --pgsql-host=$DB_HOST \
        --pgsql-port=$DB_PORT \
        --pgsql-user=$DB_USER \
        --pgsql-password=$DB_PASSWORD \
        --pgsql-db=$DB_NAME \
        --table-size=100000 \
        --tables=3 \
        --threads=$threads \
        --time=$time \
        --report-interval=10 \
        run
}

# Configurações
DB_HOST=${DB_HOST:-postgres-db}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-teste}
DB_PASSWORD=${DB_PASSWORD:-teste}
DB_NAME=${DB_NAME:-testedb}

export PGPASSWORD=$DB_PASSWORD

log "Iniciando benchmarks de consultas Sysbench..."

# Cenário 1: Read Simple
log "=== CENÁRIO READ SIMPLE ==="
run_benchmark "read_simple" 20 60

# Cenário 2: Read Range
log "=== CENÁRIO READ RANGE ==="
run_benchmark "read_range" 20 60

# Cenário 3: Read Join + Agregação
log "=== CENÁRIO READ JOIN + AGG ==="
run_benchmark "read_join_agg" 20 60

log "Benchmarks de consultas Sysbench concluídos!"
