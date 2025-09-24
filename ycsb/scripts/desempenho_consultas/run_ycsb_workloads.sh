#!/bin/bash

echo "Executando testes de desempenho de consultas no MongoDB usando YCSB..."

MONGO_URL="mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}/ycsb?authSource=admin"

run_workload() {
    local workload_name=$1
    local workload_file=$2
    
    echo "=== $workload_name ==="
    
    # Fase de carga
    echo "Fase de carga..."
    /opt/ycsb/bin/ycsb load mongodb \
        -s \
        -P "/app/workloads/$workload_file" \
        -p mongodb.url="$MONGO_URL" \
        -p mongodb.auth="true"

    # Fase de execução (somente leitura)
    echo "Fase de execução..."
    /opt/ycsb/bin/ycsb run mongodb \
        -s \
        -P "/app/workloads/$workload_file" \
        -p mongodb.url="$MONGO_URL" \
        -p mongodb.auth="true" \
        -p readallfields=true \
        -p operationcount=100000 \
        -p maxexecutiontime=300
}

# Executar todos os workloads de leitura
run_workload "LEITURA SIMPLES" "workload_read_simple"
run_workload "LEITURA COM RANGE" "workload_read_range"
run_workload "LEITURA COM AGREGAÇÕES" "workload_read_join_agg"

echo "Todos os testes de desempenho de consultas foram concluídos!"
