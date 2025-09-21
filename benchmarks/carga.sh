#!/bin/bash

echo "INICIANDO TESTES DE CARGA COMPARATIVOS"
echo "======================================"

# Executar testes no PostgreSQL
echo "Executando testes no PostgreSQL..."
docker exec sysbench-runner ../sysbench/scripts/carga/run_sysbench_workloads.sh

echo "Aguardando 5 segundos antes de iniciar testes no MongoDB..."
sleep 5

# Executar testes no MongoDB
echo "Executando testes no MongoDB..."
docker exec ycsb-runner ../ycsb/scripts/carga/run_ycsb_workloads.sh

echo "======================================"
echo "TODOS OS TESTES FORAM CONCLUÍDOS!"
echo "Os resultados estão disponíveis nos logs de cada container."