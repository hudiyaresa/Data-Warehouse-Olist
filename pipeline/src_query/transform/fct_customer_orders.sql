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

    dim_order_payments AS (
        SELECT *
        FROM final.dim_order_payments
    ),

    final_fct_customer_orders AS (
        SELECT
            do.customer_id,
            dp.product_id,
            ds.seller_id,
            do.order_id,
            dd.date_id,
            dop.payment_method_id,
            do.order_purchase_timestamp,
            do.order_status,
            dop.payment_type,
            dop.payment_value,
            updated_at
        FROM final.stg_orders do
        JOIN dim_customers dc ON dc.customer_id = do.customer_id
        JOIN dim_products dp ON dp.product_id = do.product_id
        JOIN dim_sellers ds ON ds.seller_id = do.seller_id
        JOIN dim_date dd ON dd.date = DATE(do.order_purchase_timestamp)
        JOIN dim_order_payments dop ON dop.order_id = do.order_id
    )

INSERT INTO final.fct_Customer_Order_Products (
    customer_id, product_id, seller_id, order_id, date_id, payment_method_id,
    order_purchase_timestamp, order_status, payment_type, payment_value
)
SELECT * FROM final_fct_customer_orders
ON CONFLICT (customer_id, order_id) 
DO UPDATE SET
    order_purchase_timestamp = EXCLUDED.order_purchase_timestamp,
    order_status = EXCLUDED.order_status,
    payment_type = EXCLUDED.payment_type,
    payment_value = EXCLUDED.payment_value,
    updated_at = CASE WHEN
                    final_fct_customer_orders.order_purchase_timestamp <> EXCLUDED.order_purchase_timestamp
                        OR final_fct_customer_orders.order_status <> EXCLUDED.order_status
                        OR final_fct_customer_orders.payment_type <> EXCLUDED.payment_type
                        OR final_fct_customer_orders.payment_value <> EXCLUDED.payment_value
                THEN
                    CURRENT_TIMESTAMP
                ELSE
                    final.fct_customer_orders.updated_at
                END;
