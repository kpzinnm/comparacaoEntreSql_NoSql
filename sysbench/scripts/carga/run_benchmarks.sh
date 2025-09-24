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
        --tables=3 \
        --threads=$threads \
        --time=$time \
        --report-interval=30 \
        --point-selects=$point_selects \
        --simple-ranges=$simple_ranges \
        --sum-ranges=$sum_ranges \
        --order-ranges=$order_ranges \
        --distinct-ranges=$distinct_ranges \
        --index-updates=$index_updates \
        --non-index-updates=$non_index_updates \
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

# Cenário 1: Read-Heavy (90% leitura, 10% escrita, 160 threads)
log "=== CENÁRIO READ-HEAVY ==="
run_benchmark "read_heavy" 20 300 90 10

# Cenário 2: Write-Heavy (10% leitura, 90% escrita)
log "=== CENÁRIO WRITE-HEAVY ==="
run_benchmark "write_heavy" 20 300 10 90

# Cenário 3: Balanceado (50% leitura, 50% escrita)
log "=== CENÁRIO BALANCEADO ==="
run_benchmark "balanced" 20 300 50 50

log "Benchmarks Sysbench concluídos!"