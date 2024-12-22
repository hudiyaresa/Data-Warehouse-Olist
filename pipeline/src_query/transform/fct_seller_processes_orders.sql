WITH
    dim_customers AS (
        SELECT *
        FROM final.dim_customers
    ),

    dim_products AS (
        SELECT *
        FROM final.dim_products
    ),

    dim_sellers AS (
        SELECT *
        FROM final.dim_sellers
    ),

    dim_orders AS (
        SELECT *
        FROM final.dim_orders
    ),

    dim_date AS (
        SELECT *
        FROM final.dim_date
    ),

    dim_order_items AS (
        SELECT *
        FROM final.dim_order_items
    ),

    final_fct_seller_processes_orders AS (
        SELECT
            ds.seller_id,
            dp.product_id,
            dc.customer_id,
            dd.date_id,
            do.order_id,
            doi.order_item_id,
            do.order_purchase_timestamp,
            do.order_approved_at,
            do.order_delivered_carrier_date,
            do.order_delivered_customer_date,
            do.shipping_limit_date,
            EXTRACT(EPOCH FROM (do.order_approved_at - do.order_purchase_timestamp)) AS approved_time_order,
            EXTRACT(DAY FROM (do.order_delivered_customer_date - do.shipping_limit_date)) AS seller_shipment_day
        FROM final.stg_orders do
        JOIN dim_customers dc ON dc.customer_id = do.customer_id
        JOIN dim_products dp ON dp.product_id = do.product_id
        JOIN dim_sellers ds ON ds.seller_id = dp.seller_id
        JOIN dim_date dd ON dd.date_actual = DATE(do.order_purchase_timestamp)
        JOIN dim_order_items doi ON doi.order_id = do.order_id
    )

INSERT INTO final.fct_Seller_Processes_Orders (
    seller_id, 
    product_id, 
    customer_id, 
    date_id, 
    order_id, 
    order_item_id,
    order_purchase_timestamp, 
    order_approved_at, 
    order_delivered_carrier_date, 
    order_delivered_customer_date, 
    shipping_limit_date, 
    approved_time_order, 
    seller_shipment_day
)
SELECT * FROM final_fct_seller_processes_orders
ON CONFLICT (seller_id, product_id, order_id, order_item_id)
DO UPDATE SET
    order_approved_at = EXCLUDED.order_approved_at,
    order_delivered_carrier_date = EXCLUDED.order_delivered_carrier_date,
    order_delivered_customer_date = EXCLUDED.order_delivered_customer_date,
    shipping_limit_date = EXCLUDED.shipping_limit_date,
    approved_time_order = EXCLUDED.approved_time_order,
    seller_shipment_day = EXCLUDED.seller_shipment_day,
    updated_at = CASE WHEN
                    final_fct_seller_processes_orders.order_approved_at <> EXCLUDED.order_approved_at
                    OR final_fct_seller_processes_orders.order_delivered_carrier_date <> EXCLUDED.order_delivered_carrier_date
                    OR final_fct_seller_processes_orders.order_delivered_customer_date <> EXCLUDED.order_delivered_customer_date
                    OR final_fct_seller_processes_orders.shipping_limit_date <> EXCLUDED.shipping_limit_date
                    OR final_fct_seller_processes_orders.approved_time_order <> EXCLUDED.approved_time_order
                    OR final_fct_seller_processes_orders.seller_shipment_day <> EXCLUDED.seller_shipment_day
                THEN
                    CURRENT_TIMESTAMP
                ELSE
                    final.fct_seller_processes_orders.updated_at
                END;
