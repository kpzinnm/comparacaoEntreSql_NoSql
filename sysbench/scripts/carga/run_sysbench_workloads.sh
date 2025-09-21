#!/bin/bash

# Configurações comuns
TABLES=10
TABLE_SIZE=100000
THREADS=16
DURATION=300

echo "Executando testes de carga no PostgreSQL usando Sysbench..."

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

    # Limpar (opcional)
    # sysbench $workload_file \
    #     --db-driver=pgsql \
    #     --pgsql-host=$DB_HOST \
    #     --pgsql-port=$DB_PORT \
    #     --pgsql-user=$DB_USER \
    #     --pgsql-password=$DB_PASSWORD \
    #     --pgsql-db=$DB_NAME \
    #     cleanup
}

# Executar todos os workloads
run_workload "LEITURA INTENSIVA" "read_intensive.lua"
run_workload "ESCRITA INTENSIVA" "write_intensive.lua"
run_workload "MISTO" "mixed.lua"

echo "Todos os testes de carga foram concluídos!"