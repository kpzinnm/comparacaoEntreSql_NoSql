#!/bin/bash

# Script de preparação do Sysbench para PostgreSQL
# Cria as tabelas de teste com estrutura similar ao dataset real

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

# Criar tabelas de teste para sysbench
log "Criando tabelas de teste..."

# Tabela principal para benchmarks OLTP
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME << EOF
CREATE TABLE IF NOT EXISTS sbtest1 (
    id INTEGER NOT NULL,
    k INTEGER NOT NULL,
    c VARCHAR(120) NOT NULL,
    pad CHAR(60) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS sbtest2 (
    id INTEGER NOT NULL,
    k INTEGER NOT NULL,
    c VARCHAR(120) NOT NULL,
    pad CHAR(60) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS sbtest3 (
    id INTEGER NOT NULL,
    k INTEGER NOT NULL,
    c VARCHAR(120) NOT NULL,
    pad CHAR(60) NOT NULL,
    PRIMARY KEY (id)
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS k_1 ON sbtest1(k);
CREATE INDEX IF NOT EXISTS k_2 ON sbtest2(k);
CREATE INDEX IF NOT EXISTS k_3 ON sbtest3(k);
EOF

log "Preparação do Sysbench concluída!"