CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- CREATE SCHEMA FOR STAGING
CREATE SCHEMA IF NOT EXISTS stg AUTHORIZATION postgres;

-- CUSTOMERS TABLE

CREATE TABLE stg.customers (
    id UUID DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    customer_zip_code_prefix VARCHAR(20),
    latitude real,
    longitude real,
    customer_city VARCHAR(100),
    customer_state CHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_flag VARCHAR(20) DEFAULT 'Current',
    CONSTRAINT customers_pkey PRIMARY KEY (customer_id)
);
COMMENT ON TABLE stg.customers IS 'Customer information';
COMMENT ON COLUMN stg.customers.customer_id IS 'Unique customer ID';
COMMENT ON COLUMN stg.customers.current_flag IS 'Flag for the current active record';

-- GEOLOCATION TABLE

CREATE TABLE stg.geolocation (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    geolocation_zip_code_prefix integer NOT NULL,
    geolocation_lat real,
    geolocation_lng real,
    geolocation_city text,
    geolocation_state text,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT geolocation_pk UNIQUE (geolocation_zip_code_prefix)
);

-- PRODUCT CATEGORY NAME TRANSLATION TABLE

CREATE TABLE stg.product_category_name_translation (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    product_category_name text NOT NULL,
    product_category_name_english text,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_product_category_name_translation UNIQUE (product_category_name)
);

-- PRODUCTS TABLE

CREATE TABLE stg.products (
    id UUID DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL,
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100),
    product_weight_g NUMERIC(10, 2),
    product_length_cm NUMERIC(10, 2),
    product_height_cm NUMERIC(10, 2),
    product_width_cm NUMERIC(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_flag VARCHAR(20) DEFAULT 'Current',
    CONSTRAINT products_pkey PRIMARY KEY (product_id)
);
COMMENT ON TABLE stg.products IS 'Product information';

-- SELLERS TABLE

CREATE TABLE stg.sellers (
    id UUID DEFAULT uuid_generate_v4(),
    seller_id UUID NOT NULL,
    seller_zip_code_prefix VARCHAR(20),
    latitude real,
    longitude real,
    seller_city VARCHAR(100),
    seller_state CHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_flag VARCHAR(20) DEFAULT 'Current',
    CONSTRAINT sellers_pkey PRIMARY KEY (seller_id)
);
COMMENT ON TABLE stg.sellers IS 'Seller information';

-- ORDERS TABLE

CREATE TABLE stg.orders (
    id UUID DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_flag VARCHAR(20) DEFAULT 'Current',
    CONSTRAINT orders_pkey PRIMARY KEY (order_id),
    CONSTRAINT orders_customer_fkey FOREIGN KEY (customer_id) REFERENCES stg.customers(customer_id)
);
COMMENT ON TABLE stg.orders IS 'Order information';

-- ORDER ITEMS TABLE

CREATE TABLE stg.order_items (
    id UUID DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL,
    order_item_id SERIAL,
    product_id UUID NOT NULL,
    seller_id UUID NOT NULL,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT order_items_pkey PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT order_items_order_fkey FOREIGN KEY (order_id) REFERENCES stg.orders(order_id),
    CONSTRAINT order_items_product_fkey FOREIGN KEY (product_id) REFERENCES stg.products(product_id),
    CONSTRAINT order_items_seller_fkey FOREIGN KEY (seller_id) REFERENCES stg.sellers(seller_id)
);
COMMENT ON TABLE stg.order_items IS 'Order item details';

-- PAYMENTS TABLE

CREATE TABLE stg.order_payments (
    id UUID DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value NUMERIC(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_flag VARCHAR(20) DEFAULT 'Current',
    CONSTRAINT payments_pkey PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT payments_order_fkey FOREIGN KEY (order_id) REFERENCES stg.orders(order_id)
);
COMMENT ON TABLE stg.order_payments IS 'Payment information';

-- REVIEWS TABLE

CREATE TABLE stg.order_reviews (
    id UUID DEFAULT uuid_generate_v4(),
    review_id UUID NOT NULL,
    order_id UUID NOT NULL,
    review_score INT CHECK (review_score BETWEEN 1 AND 5),
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT reviews_pkey PRIMARY KEY (review_id, order_id),    
    CONSTRAINT reviews_order_fkey FOREIGN KEY (order_id) REFERENCES stg.orders(order_id)
);

COMMENT ON TABLE stg.order_reviews IS 'Order reviews';