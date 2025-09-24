#!/bin/bash

# Script de preparação do Sysbench para PostgreSQL
# Este script cria as tabelas e as popula com dados de teste.

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log "Preparando ambiente Sysbench para PostgreSQL..."


# Configurações
DB_HOST=${DB_HOST:-postgres-db}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-teste}
DB_PASSWORD=${DB_PASSWORD:-teste}
DB_NAME=${DB_NAME:-testedb}

export PGPASSWORD=$DB_PASSWORD

log "Executando a fase de preparação do Sysbench..."

# A fase 'prepare' do Sysbench cria as tabelas e insere os dados
sysbench oltp_read_write \
    --db-driver=pgsql \
    --pgsql-host=$DB_HOST \
    --pgsql-port=$DB_PORT \
    --pgsql-user=$DB_USER \
    --pgsql-password=$DB_PASSWORD \
    --pgsql-db=$DB_NAME \
    --tables=$TABLES \
    --table-size=$TABLE_SIZE \
    --threads=$THREADS \
    prepare

log "Preparação do Sysbench concluída! As tabelas estão prontas para o teste."