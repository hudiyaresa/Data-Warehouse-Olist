CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- CREATE SCHEMA FOR FINAL AREA
CREATE SCHEMA IF NOT EXISTS final AUTHORIZATION postgres;

---------------------------------------------------------------------------------------------------------------------------------
-- FINAL SCHEMA

-- Customers Table
DROP TABLE IF EXISTS final.dim_customer;
CREATE TABLE final.dim_customer (
    customer_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_nk VARCHAR(255) NOT NULL,
    customer_unique_id VARCHAR(255) NOT NULL,
    customer_zip_code_prefix VARCHAR(10) NOT NULL,
    latitude FLOAT,
    longitude FLOAT,
    customer_city VARCHAR(255),
    customer_state VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_flag VARCHAR(20) DEFAULT 'Current'
);

-- Sellers Table
DROP TABLE IF EXISTS final.dim_seller;
CREATE TABLE final.dim_seller (
    seller_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    seller_nk VARCHAR(255) NOT NULL,
    seller_zip_code_prefix VARCHAR(10) NOT NULL,
    latitude FLOAT,
    longitude FLOAT,
    seller_city VARCHAR(255),
    seller_state VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_flag VARCHAR(20) DEFAULT 'Current'
);

-- Products Table
DROP TABLE IF EXISTS final.dim_product;
CREATE TABLE final.dim_product (
    product_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g NUMERIC(10, 2),
    product_length_cm NUMERIC(10, 2),
    product_height_cm NUMERIC(10, 2),
    product_width_cm NUMERIC(10, 2),
    product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
DROP TABLE IF EXISTS final.fct_order;
CREATE TABLE final.fct_order (
    order_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    order_nk VARCHAR(255) NOT NULL,
    customer_id UUID NOT NULL REFERENCES customer(customer_id),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_flag VARCHAR(20) DEFAULT 'Current'
);

-- Order Items Table
DROP TABLE IF EXISTS final.fct_order_item;
CREATE TABLE final.fct_order_item (
    order_item_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    order_item_nk VARCHAR(255) NOT NULL UNIQUE,
    price NUMERIC(10, 2) NOT NULL,
    freight_value NUMERIC(10, 2),
    order_id UUID NOT NULL REFERENCES orders(order_id),
    product_id UUID NOT NULL REFERENCES product(product_id),
    seller_id UUID NOT NULL REFERENCES seller(seller_id),
    shipping_limit_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment Table
DROP TABLE IF EXISTS final.fct_payment;
CREATE TABLE final.fct_payment (
    payment_method_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    payment_sequential INT NOT NULL,
    payment_installments INT NOT NULL,
    payment_value NUMERIC(10, 2) NOT NULL,
    order_id UUID NOT NULL REFERENCES orders(order_id),
    payment_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_flag VARCHAR(20) DEFAULT 'Current'
);

-- Date Table
DROP TABLE if exists final.dim_date;
CREATE TABLE final.dim_date
(
    date_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    date DATE NOT NULL UNIQUE,
    full_date DATE NOT NULL UNIQUE,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20),
    month_name VARCHAR(20),
);

-- Indices for Performance
CREATE INDEX idx_customer_email ON final.dim_customer(email);
CREATE INDEX idx_seller_email ON final.dim_seller(email);
CREATE INDEX idx_product_name ON final.dim_product(product_name);
CREATE INDEX idx_order_date ON final.fct_order(order_date);
CREATE INDEX idx_payment_date ON final.fct_payment(payment_date);
