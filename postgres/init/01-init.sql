-- Criar schema para dados Olist
CREATE SCHEMA IF NOT EXISTS olist;

-- Tabelas do dataset Olist (apenas estrutura, os dados serão carregados via CSV)
CREATE TABLE IF NOT EXISTS olist.customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

-- Adicione outras tabelas do dataset conforme necessário
-- (orders, order_items, products, etc.)
