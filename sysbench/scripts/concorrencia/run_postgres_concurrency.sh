#!/bin/bash
set -e

THREADS_LIST="10 50 100"
RESULTS_DIR="/app/results"

mkdir -p $RESULTS_DIR

for t in $THREADS_LIST; do
    echo "Rodando teste de concorrência PostgreSQL com $t threads..."
    sysbench /app/scripts/concorrencia/pg_concurrency.lua \
        --db-driver=pgsql \
        --pgsql-host=$DB_HOST \
        --pgsql-port=$DB_PORT \
        --pgsql-user=$DB_USER \
        --pgsql-password=$DB_PASSWORD \
        --pgsql-db=$DB_NAME \
        --time=60 \
        --threads=$t \
        run | tee $RESULTS_DIR/postgres_concurrency_${t}.log
done
