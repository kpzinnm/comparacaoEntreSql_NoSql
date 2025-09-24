#!/bin/bash
set -e

THREADS_LIST="10 50 100"
RESULTS_DIR="/app/results"

mkdir -p $RESULTS_DIR

for t in $THREADS_LIST; do
    echo "Rodando teste de concorrência MongoDB com $t threads..."
    ./bin/ycsb run mongodb -s \
        -P workloads/workload_balanced \
        -p mongodb.url="mongodb://teste:teste@mongo-db:27017/ycsb?w=1" \
        -threads $t \
        -p recordcount=10000 \
        -p operationcount=5000 \
        > $RESULTS_DIR/mongo_concurrency_${t}.log
done
