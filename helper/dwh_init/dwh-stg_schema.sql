-- Data Warehouse Staging Schema

-- Create UUID extension if not exist yet
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the schema if not exist yet
CREATE SCHEMA IF NOT EXISTS stg AUTHORIZATION postgres;

------------------------------------------------------------------------------------------

-- CREATE TABLE

--
-- Name: geolocation; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE stg.geolocation (
    id uuid default uuid_generate_v4(),
    geolocation_zip_code_prefix integer NOT NULL,
    geolocation_lat real,
    geolocation_lng real,
    geolocation_city text,
    geolocation_state text,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: customers; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE stg.customers (
    id uuid default uuid_generate_v4(),
    customer_id text NOT NULL,
    customer_unique_id text,
    customer_zip_code_prefix integer,
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6),
    customer_city text,
    customer_state text,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: order_items; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE stg.order_items (
    id uuid default uuid_generate_v4(),
    order_id text NOT NULL,
    order_item_id varchar NOT NULL,
    product_id text,
    seller_id text,
    shipping_limit_date text,
    price real,
    freight_value real,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: order_payments; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE stg.order_payments (
    id uuid default uuid_generate_v4(),
    order_id text NOT NULL,
    payment_sequential integer NOT NULL,
    payment_type text,
    payment_installments integer,
    payment_value real,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: order_reviews; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE stg.order_reviews (
    id uuid default uuid_generate_v4(),
    review_id text NOT NULL,
    order_id text NOT NULL,
    review_score integer,
    review_comment_title text,
    review_comment_message text,
    review_creation_date text,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: orders; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE stg.orders (
    id uuid default uuid_generate_v4(),
    order_id text NOT NULL,
    customer_id text,
    order_status text,
    order_purchase_timestamp text,
    order_approved_at text,
    order_delivered_carrier_date text,
    order_delivered_customer_date text,
    order_estimated_delivery_date text,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: public_category_name_translation; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE stg.product_category_name_translation (
    id uuid default uuid_generate_v4(),
    product_category_name text NOT NULL,
    product_category_name_english text,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: products; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE stg.products (
    id uuid default uuid_generate_v4(),
    product_id text NOT NULL,
    product_category_name text,
    product_category_name_english text,
    product_name_lenght real,
    product_description_lenght real,
    product_photos_qty real,
    product_weight_g real,
    product_length_cm real,
    product_height_cm real,
    product_width_cm real,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: sellers; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE stg.sellers (
    id uuid default uuid_generate_v4(),
    seller_id text NOT NULL,
    seller_zip_code_prefix integer,
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6),
    seller_city text,
    seller_state text,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

------------------------------------------------------------------------------------------

-- ADD PRIMARY KEY FOR EACH TABLES

--
-- Name: geolocation geolocation_pk; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY stg.geolocation
    ADD CONSTRAINT geolocation_pk PRIMARY KEY (geolocation_zip_code_prefix);

--
-- Name: customers pk_customers; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY stg.customers
    ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);

--
-- Name: order_items pk_order_items; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY stg.order_items
    ADD CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id);

--
-- Name: order_payments pk_order_payments; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY stg.order_payments
    ADD CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential);

--
-- Name: order_reviews pk_order_reviews; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY stg.order_reviews
    ADD CONSTRAINT pk_order_reviews PRIMARY KEY (review_id, order_id);

--
-- Name: orders pk_orders; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY stg.orders
    ADD CONSTRAINT pk_orders PRIMARY KEY (order_id);

--
-- Name: product_category_name_translation pk_product_category_name_translation; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY stg.product_category_name_translation
    ADD CONSTRAINT pk_product_category_name_translation PRIMARY KEY (product_category_name);

--
-- Name: products pk_products; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY stg.products
    ADD CONSTRAINT pk_products PRIMARY KEY (product_id);

--
-- Name: sellers pk_sellers; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY stg.sellers
    ADD CONSTRAINT pk_sellers PRIMARY KEY (seller_id);

------------------------------------------------------------------------------------------

-- ADD FOREIGN KEY FOR EACH TABLES (CREATE A RELATION)

--
-- Name: customers fk_cust_geo_prefix; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

-- ALTER TABLE ONLY stg.customers
    -- ADD CONSTRAINT fk_cust_geo_prefix FOREIGN KEY (customer_zip_code_prefix) REFERENCES stg.geolocation(geolocation_zip_code_prefix);

--
-- Name: order_items fk_order_items_orders; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

-- ALTER TABLE ONLY stg.order_items
    -- ADD CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id) REFERENCES stg.orders(order_id);

--
-- Name: order_items fk_order_items_products; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

-- ALTER TABLE ONLY stg.order_items
    -- ADD CONSTRAINT fk_order_items_products FOREIGN KEY (product_id) REFERENCES stg.products(product_id);

--
-- Name: order_items fk_order_items_sellers; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

-- ALTER TABLE ONLY stg.order_items
    -- ADD CONSTRAINT fk_order_items_sellers FOREIGN KEY (seller_id) REFERENCES stg.sellers(seller_id);

--
-- Name: order_payments fk_order_payments_orders; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

-- ALTER TABLE ONLY stg.order_payments
    -- ADD CONSTRAINT fk_order_payments_orders FOREIGN KEY (order_id) REFERENCES stg.orders(order_id);

--
-- Name: order_reviews fk_order_reviews_orders; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

-- ALTER TABLE ONLY stg.order_reviews
    -- ADD CONSTRAINT fk_order_reviews_orders FOREIGN KEY (order_id) REFERENCES stg.orders(order_id);

--
-- Name: orders fk_orders_customers; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

-- ALTER TABLE ONLY stg.orders
    -- ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES stg.customers(customer_id);

--
-- Name: products fk_products_product_category; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

-- ALTER TABLE ONLY stg.products
    -- ADD CONSTRAINT fk_products_product_category FOREIGN KEY (product_category_name) REFERENCES stg.product_category_name_translation(product_category_name);
    
--
-- Name: sellers fk_seller_geo_prefix; Type: FK CONSTRAINT; Schema: staging; Owner: postgres
--

-- ALTER TABLE ONLY stg.sellers
    -- ADD CONSTRAINT fk_seller_geo_prefix FOREIGN KEY (seller_zip_code_prefix) REFERENCES stg.geolocation(geolocation_zip_code_prefix);
