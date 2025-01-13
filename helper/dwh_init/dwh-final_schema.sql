    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

    -- CREATE SCHEMA FOR FINAL AREA
    CREATE SCHEMA IF NOT EXISTS final AUTHORIZATION postgres;

    ---------------------------------------------------------------------------------------------------------------------------------
    -- FINAL SCHEMA

    -- Customers Table
    DROP TABLE IF EXISTS final.dim_customers;
    CREATE TABLE final.dim_customers (
        customer_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        customer_nk VARCHAR(255) NOT NULL UNIQUE,
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
        seller_id TEXT DEFAULT uuid_generate_v4() PRIMARY KEY,
        seller_nk VARCHAR(255) NOT NULL UNIQUE,
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
        product_id TEXT DEFAULT uuid_generate_v4() PRIMARY KEY,
        product_name_length INT,
        product_description_length INT,  -- Perbaiki typo "product_description_lenght"
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
        order_id TEXT DEFAULT uuid_generate_v4() PRIMARY KEY,
        order_nk TEXT NOT NULL,
        customer_nk VARCHAR(255) NOT NULL,  
        order_status VARCHAR(50),
        order_purchase_timestamp TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        current_flag VARCHAR(20) DEFAULT 'Current'
    );

    -- Order Items Table (Composite Key on order_id and order_item_id)
    DROP TABLE IF EXISTS final.dim_order_items;
    CREATE TABLE final.dim_order_items (
        order_item_id VARCHAR,
        order_item_nk VARCHAR(255) NOT NULL,
        price NUMERIC(10, 2) NOT NULL,
        freight_value NUMERIC(10, 2),
        order_nk TEXT NOT NULL, 
        product_id TEXT NOT NULL, 
        seller_nk TEXT NOT NULL, 
        shipping_limit_date TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT pk_order_item PRIMARY KEY (order_nk, order_item_id)  -- Composite Primary Key
    );

    -- Payment Table (Composite Key on order_nk and payment_sequential)
    DROP TABLE IF EXISTS final.dim_order_payments;
    CREATE TABLE final.dim_order_payments (
        payment_method_id UUID DEFAULT uuid_generate_v4(),
        payment_sequential INT NOT NULL,
        payment_installments INT NOT NULL,
        payment_value NUMERIC(10, 2) NOT NULL,
        order_nk TEXT NOT NULL, 
        payment_type VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        current_flag VARCHAR(20) DEFAULT 'Current',
        CONSTRAINT pk_order_payment PRIMARY KEY (order_nk, payment_sequential)  -- Composite Primary Key
    );

    -- Date Table
    DROP TABLE IF EXISTS final.dim_date;
    CREATE TABLE final.dim_date (
        date_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        date_actual              DATE NOT NULL,
        day_suffix               VARCHAR(4) NOT NULL,
        day_name                 VARCHAR(9) NOT NULL,
        day_of_year              INT NOT NULL,
        week_of_month            INT NOT NULL,
        week_of_year             INT NOT NULL,
        week_of_year_iso         CHAR(10) NOT NULL,
        month_actual             INT NOT NULL,
        month_name               VARCHAR(9) NOT NULL,
        month_name_abbreviated   CHAR(3) NOT NULL,
        quarter_actual           INT NOT NULL,
        quarter_name             VARCHAR(9) NOT NULL,
        year_actual              INT NOT NULL,
        first_day_of_week        DATE NOT NULL,
        last_day_of_week         DATE NOT NULL,
        first_day_of_month       DATE NOT NULL,
        last_day_of_month        DATE NOT NULL,
        first_day_of_quarter     DATE NOT NULL,
        last_day_of_quarter      DATE NOT NULL,
        first_day_of_year        DATE NOT NULL,
        last_day_of_year         DATE NOT NULL,
        mmyyyy                   CHAR(6) NOT NULL,
        mmddyyyy                 CHAR(10) NOT NULL,
        weekend_indr             VARCHAR(20) NOT NULL
    );

    -- Fct Table Customer Order
    DROP TABLE IF EXISTS final.fct_customer_orders;
    CREATE TABLE final.fct_customer_orders (
        customer_order_id SERIAL PRIMARY KEY,
        customer_id UUID,
        customer_unique_id VARCHAR(255),
        customer_city VARCHAR(255),
        product_id TEXT,
        product_category_name_english VARCHAR(255),
        order_id TEXT,
        order_item_id VARCHAR,
        seller_id TEXT,
        order_purchase_timestamp TIMESTAMP,
        date_id UUID,
        payment_sequential INT,
        CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES final.dim_customers(customer_id),
        CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES final.dim_products(product_id),
        CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES final.dim_orders(order_nk),
        CONSTRAINT fk_seller FOREIGN KEY (seller_id) REFERENCES final.dim_sellers(seller_id),
        CONSTRAINT fk_payment FOREIGN KEY (order_id, payment_sequential) REFERENCES final.dim_order_payments(order_nk, payment_sequential),
        CONSTRAINT fk_date FOREIGN KEY (date_id) REFERENCES final.dim_date(date_id)
    );

    -- Fct Table Seller Processes Orders
    DROP TABLE IF EXISTS final.fct_seller_processes_orders;
    CREATE TABLE final.fct_seller_processes_orders (
        seller_processes_id SERIAL PRIMARY KEY,
        seller_id TEXT,
        product_id TEXT,
        customer_id UUID,
        date_id UUID,
        order_id TEXT,
        order_purchase_timestamp TIMESTAMP,
        order_approved_at TIMESTAMP,
        order_delivered_carrier_date TIMESTAMP,
        order_delivered_customer_date TIMESTAMP,
        order_item_id VARCHAR,
        shipping_limit_date TIMESTAMP,
        CONSTRAINT fk_seller_processes FOREIGN KEY (seller_id) REFERENCES final.dim_sellers(seller_id),
        CONSTRAINT fk_product_processes FOREIGN KEY (product_id) REFERENCES final.dim_products(product_id),
        CONSTRAINT fk_customer_processes FOREIGN KEY (customer_id) REFERENCES final.dim_customers(customer_id),
        CONSTRAINT fk_order_processes FOREIGN KEY (order_id) REFERENCES final.dim_orders(order_nk),
        CONSTRAINT fk_date_processes FOREIGN KEY (date_id) REFERENCES final.dim_date(date_id)
    );

    -- Fct Table Customer Review Delivered Products (Composite Key on order_id and review_id)
    DROP TABLE IF EXISTS final.fct_customer_review_delivered_products;
    CREATE TABLE final.fct_customer_review_delivered_products (
        customer_review_id UUID,
        customer_id UUID,
        product_id TEXT,
        seller_id TEXT,
        date_id UUID,
        review_id INT,
        order_id TEXT,
        review_score INT,
        review_comment_title VARCHAR(255),
        review_comment_message TEXT UNIQUE,
        on_time_delivery_status BOOLEAN,
        total_days_delay_delivery INT,
        CONSTRAINT pk_review PRIMARY KEY (order_id, review_id),  -- Composite Primary Key
        CONSTRAINT fk_customer_review FOREIGN KEY (customer_id) REFERENCES final.dim_customers(customer_id),
        CONSTRAINT fk_product_review FOREIGN KEY (product_id) REFERENCES final.dim_products(product_id),
        CONSTRAINT fk_seller_review FOREIGN KEY (seller_id) REFERENCES final.dim_sellers(seller_id),
        CONSTRAINT fk_date_review FOREIGN KEY (date_id) REFERENCES final.dim_date(date_id)
    );



    -- Menambahkan Foreign Key Constraints setelah semua tabel dibuat
    ALTER TABLE final.dim_orders ADD CONSTRAINT fk_customer_nk FOREIGN KEY (customer_nk) REFERENCES final.dim_customers(customer_nk);
    ALTER TABLE final.dim_order_items ADD CONSTRAINT fk_order_nk FOREIGN KEY (order_nk) REFERENCES final.dim_orders(order_nk);
    ALTER TABLE final.dim_order_items ADD CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES final.dim_products(product_id);
    ALTER TABLE final.dim_order_items ADD CONSTRAINT fk_seller_nk FOREIGN KEY (seller_nk) REFERENCES final.dim_sellers(seller_id);
    ALTER TABLE final.dim_order_payments ADD CONSTRAINT fk_order_payment FOREIGN KEY (order_nk) REFERENCES final.dim_orders(order_nk);