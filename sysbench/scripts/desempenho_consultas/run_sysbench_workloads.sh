#!/bin/bash

# Configurações comuns
TABLES=3
TABLE_SIZE=100000
THREADS=16
DURATION=300

echo "Executando testes de desempenho de consultas no PostgreSQL usando Sysbench..."

run_workload() {
    
    local workload_name=$1
    local workload_file=$2
    
    echo "=== $workload_name ==="
    
    # Preparar o banco
    sysbench $workload_file \
        --db-driver=pgsql \
        --pgsql-host=$DB_HOST \
        --pgsql-port=$DB_PORT \
        --pgsql-user=$DB_USER \
        --pgsql-password=$DB_PASSWORD \
        --pgsql-db=$DB_NAME \
        --tables=$TABLES \
        --table-size=$TABLE_SIZE \
        prepare

    # Executar o workload
    sysbench $workload_file \
        --db-driver=pgsql \
        --pgsql-host=$DB_HOST \
        --pgsql-port=$DB_PORT \
        --pgsql-user=$DB_USER \
        --pgsql-password=$DB_PASSWORD \
        --pgsql-db=$DB_NAME \
        --threads=$THREADS \
        --time=$DURATION \
        --report-interval=10 \
        run

    # Limpeza opcional
    # sysbench $workload_file \
    #     --db-driver=pgsql \
    #     --pgsql-host=$DB_HOST \
    #     --pgsql-port=$DB_PORT \
    #     --pgsql-user=$DB_USER \
    #     --pgsql-password=$DB_PASSWORD \
    #     --pgsql-db=$DB_NAME \
    #     cleanup
}

# Executar todos os workloads de leitura
run_workload "LEITURA SIMPLES" "read_simple.lua"
run_workload "LEITURA COM RANGE" "read_range.lua"
run_workload "LEITURA COM JOIN E AGREGAÇÕES" "read_join_agg.lua"

echo "Todos os testes de desempenho de consultas foram concluídos!"
