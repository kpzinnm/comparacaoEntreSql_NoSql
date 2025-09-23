-- Schema completo para Brazilian E-commerce Dataset
CREATE TABLE IF NOT EXISTS olist_customers_dataset (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);

CREATE TABLE IF NOT EXISTS olist_geolocation_dataset (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat DECIMAL(10,8),
    geolocation_lng DECIMAL(11,8),
    geolocation_city TEXT,
    geolocation_state TEXT
);

CREATE TABLE IF NOT EXISTS olist_orders_dataset (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE IF NOT EXISTS olist_order_items_dataset (
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS olist_order_payments_dataset (
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS olist_order_reviews_dataset (
    review_id TEXT,
    order_id TEXT,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE IF NOT EXISTS olist_products_dataset (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

CREATE TABLE IF NOT EXISTS olist_sellers_dataset (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state TEXT
);

CREATE TABLE IF NOT EXISTS product_category_name_translation (
    product_category_name TEXT,
    product_category_name_english TEXT
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_customers_city ON olist_customers_dataset(customer_city);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON olist_orders_dataset(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON olist_orders_dataset(order_status);
CREATE INDEX IF NOT EXISTS idx_products_category ON olist_products_dataset(product_category_name);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON olist_order_items_dataset(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON olist_order_items_dataset(order_id);
CREATE INDEX IF NOT EXISTS idx_order_payments_order ON olist_order_payments_dataset(order_id);
CREATE INDEX IF NOT EXISTS idx_order_reviews_order ON olist_order_reviews_dataset(order_id);
CREATE INDEX IF NOT EXISTS idx_sellers_city ON olist_sellers_dataset(seller_city);