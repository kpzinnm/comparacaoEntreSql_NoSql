#!/bin/bash

echo "Executando testes de carga no MongoDB usando YCSB..."

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

    # Fase de execução
    echo "Fase de execução..."
    /opt/ycsb/bin/ycsb run mongodb \
        -s \
        -P "/app/workloads/$workload_file" \
        -p mongodb.url="$MONGO_URL" \
        -p mongodb.auth="true"
}

# Executar todos os workloads
run_workload "LEITURA INTENSIVA" "workload_read_intensive"
run_workload "ESCRITA INTENSIVA" "workload_write_intensive"
run_workload "MISTO" "workload_mixed"

echo "Todos os testes de carga foram concluídos!"