#!/bin/bash

# Script para executar benchmarks Sysbench

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

run_benchmark() {
    local scenario=$1
    local threads=$2
    local time=$3
    local read_proportion=$4
    local write_proportion=$5
    
    log "Executando cenário: $scenario"
    log "Threads: $threads, Duração: ${time}s, Leitura: ${read_proportion}%, Escrita: ${write_proportion}%"
    
    # Calcular proporções baseadas na divisão 20 operações totais
    local total_ops=20
    local total_reads=$((read_proportion * total_ops / 100))
    local point_selects=$((total_reads / 5))
    local simple_ranges=$((total_reads / 5))
    local sum_ranges=$((total_reads / 5))
    local order_ranges=$((total_reads / 5))
    local distinct_ranges=$((total_reads / 5))
    local index_updates=$((write_proportion * total_ops / 100))
    local non_index_updates=$((write_proportion * total_ops / 100))
    
    
    sysbench oltp_read_write \
        --db-driver=pgsql \
        --pgsql-host=$DB_HOST \
        --pgsql-port=$DB_PORT \
        --pgsql-user=$DB_USER \
        --pgsql-password=$DB_PASSWORD \
        --pgsql-db=$DB_NAME \
        --table-size=100000 \
        --tables=8 \
        --threads=$threads \
        --time=$time \
        --report-interval=30 \
        run
}

# Configurações
DB_HOST=${DB_HOST:-postgres-db}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-teste}
DB_PASSWORD=${DB_PASSWORD:-teste}
DB_NAME=${DB_NAME:-testedb}

export PGPASSWORD=$DB_PASSWORD

log "Iniciando benchmarks Sysbench..."

# NÍVEL 1: Estresse Moderado (100 threads)
log "=== NÍVEL 1: ESTRESSE MODERADO (100 threads) ==="
log "=== CENÁRIO READ-HEAVY ==="
run_benchmark "read_heavy_moderate" 100 300 95 5

log "=== CENÁRIO WRITE-HEAVY ==="
run_benchmark "write_heavy_moderate" 100 300 5 95

log "=== CENÁRIO BALANCEADO ==="
run_benchmark "balanced_moderate" 100 300 50 50

# NÍVEL 2: Estresse Alto (200 threads)
log "=== NÍVEL 2: ESTRESSE ALTO (200 threads) ==="
log "=== CENÁRIO READ-HEAVY ==="
run_benchmark "read_heavy_high" 200 300 95 5

log "=== CENÁRIO WRITE-HEAVY ==="
run_benchmark "write_heavy_high" 200 300 5 95

log "=== CENÁRIO BALANCEADO ==="
run_benchmark "balanced_high" 200 300 50 50

# NÍVEL 3: Estresse Extremo (280 threads - próximo ao limite)
log "=== NÍVEL 3: ESTRESSE EXTREMO (280 threads) ==="
log "=== CENÁRIO READ-HEAVY ==="
run_benchmark "read_heavy_extreme" 280 300 95 5

log "=== CENÁRIO WRITE-HEAVY ==="
run_benchmark "write_heavy_extreme" 280 300 5 95

log "=== CENÁRIO BALANCEADO ==="
run_benchmark "balanced_extreme" 280 300 50 50

log "Benchmarks Sysbench concluídos!"