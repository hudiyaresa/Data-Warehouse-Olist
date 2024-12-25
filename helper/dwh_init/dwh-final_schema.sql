CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- CREATE SCHEMA FOR FINAL AREA
CREATE SCHEMA IF NOT EXISTS final AUTHORIZATION postgres;

---------------------------------------------------------------------------------------------------------------------------------
-- FINAL SCHEMA

-- Customers Table
DROP TABLE IF EXISTS final.dim_customers;
CREATE TABLE final.dim_customers (
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
DROP TABLE IF EXISTS final.dim_sellers;
CREATE TABLE final.dim_sellers (
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
DROP TABLE IF EXISTS final.dim_products;
CREATE TABLE final.dim_products (
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
DROP TABLE IF EXISTS final.dim_orders;
CREATE TABLE final.dim_orders (
    order_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    order_nk VARCHAR(255) NOT NULL,
    customer_nk UUID NOT NULL REFERENCES dim_customers(customer_nk),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_flag VARCHAR(20) DEFAULT 'Current'
);

-- Order Items Table
DROP TABLE IF EXISTS final.dim_order_items;
CREATE TABLE final.dim_order_items (
    order_item_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    order_item_nk VARCHAR(255) NOT NULL UNIQUE,
    price NUMERIC(10, 2) NOT NULL,
    freight_value NUMERIC(10, 2),
    order_nk INT NOT NULL REFERENCES dim_orders(order_nk),
    product_id INT NOT NULL REFERENCES dim_products(product_id),
    seller_nk INT NOT NULL REFERENCES dim_sellers(seller_nk),
    shipping_limit_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment Table
DROP TABLE IF EXISTS final.dim_order_payments;
CREATE TABLE final.dim_order_payments (
    payment_method_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    payment_sequential INT NOT NULL,
    payment_installments INT NOT NULL,
    payment_value NUMERIC(10, 2) NOT NULL,
    order_nk INT NOT NULL REFERENCES orders(order_nk),
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

-- Fct Table Customer Order
DROP TABLE if exists final.fct_customer_orders;
CREATE TABLE final.fct_customer_orders (
    customer_order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES dim_customers(customer_id),
    customer_unique_id VARCHAR(255),
    customer_city VARCHAR(255),
    product_id INT REFERENCES dim_products(product_id),
    product_category_name_english VARCHAR(255),
    order_id INT REFERENCES dim_orders(order_id),
    order_item_id INT,
    seller_id INT REFERENCES dim_sellers(seller_id),
    order_purchase_timestamp TIMESTAMP,
    payment_sequential INT REFERENCES dim_order_payments(payment_sequential),
    date_id INT REFERENCES dim_date(date_id)
);

-- Fct Table Seller Processes Orders
DROP TABLE if exists final.fct_seller_processes_orders;
CREATE TABLE final.fct_seller_processes_orders (
    seller_processes_id SERIAL PRIMARY KEY,
    seller_id INT REFERENCES dim_sellers(seller_id),
    product_id INT REFERENCES dim_products(product_id),
    customer_id INT REFERENCES dim_customers(customer_id),
    date_id INT REFERENCES dim_date(date_id),
    order_id INT REFERENCES dim_orders(order_id),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_item_id INT,
    shipping_limit_date TIMESTAMP
);

-- Fct Table Customer Review Delivered Products
DROP TABLE if exists final.fct_customer_review_delivered_products;
CREATE TABLE final.fct_customer_review_delivered_products (
    customer_review_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES dim_customers(customer_id),
    product_id INT REFERENCES dim_products(product_id),
    seller_id INT REFERENCES dim_sellers(seller_id),
    date_id INT REFERENCES dim_date(date_id),
    review_id INT REFERENCES dim_order_reviews(review_id),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    on_time_delivery_status BOOLEAN,
    total_days_delay_delivery INT
);



-- Indices for Performance
CREATE INDEX idx_customer_email ON final.dim_customers(email);
CREATE INDEX idx_seller_email ON final.dim_sellers(email);
CREATE INDEX idx_product_name ON final.dim_products(product_name);
CREATE INDEX idx_order_date ON final.fct_order(order_date);
CREATE INDEX idx_payment_date ON final.dim_order_payments(payment_date);
