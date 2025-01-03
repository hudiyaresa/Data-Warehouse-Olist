--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    customer_id text NOT NULL,
    customer_unique_id text,
    customer_zip_code_prefix integer,
    customer_city text,
    customer_state text
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: geolocation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.geolocation (
    geolocation_zip_code_prefix integer NOT NULL,
    geolocation_lat real,
    geolocation_lng real,
    geolocation_city text,
    geolocation_state text
);


ALTER TABLE public.geolocation OWNER TO postgres;

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    order_id text NOT NULL,
    order_item_id integer NOT NULL,
    product_id text,
    seller_id text,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2)
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_payments (
    order_id text NOT NULL,
    payment_sequential integer NOT NULL,
    payment_type text,
    payment_installments integer,
    payment_value NUMERIC(10, 2)
);


ALTER TABLE public.order_payments OWNER TO postgres;

--
-- Name: order_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_reviews (
    review_id text NOT NULL,
    order_id text NOT NULL,
    review_score integer CHECK (review_score BETWEEN 1 AND 5),
    review_comment_title text,
    review_comment_message text,
    review_creation_date TIMESTAMP
);


ALTER TABLE public.order_reviews OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id text NOT NULL,
    customer_id text,
    order_status text,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: product_category_name_translation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_category_name_translation (
    product_category_name text NOT NULL,
    product_category_name_english text
);


ALTER TABLE public.product_category_name_translation OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id text NOT NULL,
    product_category_name text,
    product_name_lenght real,
    product_description_lenght real,
    product_photos_qty real,
    product_weight_g real,
    product_length_cm real,
    product_height_cm real,
    product_width_cm real
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: sellers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sellers (
    seller_id text NOT NULL,
    seller_zip_code_prefix integer,
    seller_city text,
    seller_state text
);


ALTER TABLE public.sellers OWNER TO postgres;

--
-- Name: geolocation geolocation_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.geolocation
    ADD CONSTRAINT geolocation_pk PRIMARY KEY (geolocation_zip_code_prefix);


--
-- Name: customers pk_customers; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);


--
-- Name: order_items pk_order_items; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id);


--
-- Name: order_payments pk_order_payments; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_payments
    ADD CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential);


--
-- Name: order_reviews pk_order_reviews; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT pk_order_reviews PRIMARY KEY (review_id, order_id);


--
-- Name: orders pk_orders; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT pk_orders PRIMARY KEY (order_id);


--
-- Name: product_category_name_translation pk_product_category_name_translation; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category_name_translation
    ADD CONSTRAINT pk_product_category_name_translation PRIMARY KEY (product_category_name);


--
-- Name: products pk_products; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT pk_products PRIMARY KEY (product_id);


--
-- Name: sellers pk_sellers; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT pk_sellers PRIMARY KEY (seller_id);


--
-- Name: customers fk_cyst_geo_prefix; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_cyst_geo_prefix FOREIGN KEY (customer_zip_code_prefix) REFERENCES public.geolocation(geolocation_zip_code_prefix);


--
-- Name: order_items fk_order_items_orders; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: order_items fk_order_items_products; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_items_products FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: order_items fk_order_items_sellers; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_items_sellers FOREIGN KEY (seller_id) REFERENCES public.sellers(seller_id);


--
-- Name: order_payments fk_order_payments_orders; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_payments
    ADD CONSTRAINT fk_order_payments_orders FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: order_reviews fk_order_reviews_orders; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT fk_order_reviews_orders FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: orders fk_orders_customers; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- Name: products fk_products_product_category; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_products_product_category FOREIGN KEY (product_category_name) REFERENCES public.product_category_name_translation(product_category_name);


--
-- Name: sellers fk_seller_geo_prefix; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT fk_seller_geo_prefix FOREIGN KEY (seller_zip_code_prefix) REFERENCES public.geolocation(geolocation_zip_code_prefix);


--
-- PostgreSQL database dump complete
--

