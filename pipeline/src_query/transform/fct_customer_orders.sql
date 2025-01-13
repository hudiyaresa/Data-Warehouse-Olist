WITH
    stg_orders AS (
        SELECT * 
        FROM stg.orders
    ),

    stg_order_items AS (
        SELECT *
        FROM stg.order_items
    ),

    dim_products AS (
        SELECT * 
        FROM final.dim_products
    ),

    dim_customers AS (
        SELECT * 
        FROM final.dim_customers
    ),

    dim_sellers AS (
        SELECT * 
        FROM final.dim_sellers
    ),

    dim_order_status AS (
        SELECT * 
        FROM final.dim_order_status
    ),

    dim_date AS (
        SELECT * 
        FROM final.dim_date
    ),

    aggregated_order_items AS (
        SELECT
            oi.order_id,
            dp.product_id,
            ds.seller_id,
            COUNT(oi.order_item_id) AS total_quantity,
            SUM(oi.price) AS total_price,
            SUM(oi.freight_value) AS total_freight
        FROM
            stg_order_items oi
        JOIN
            dim_products dp ON oi.product_id = dp.product_nk
        JOIN
            dim_sellers ds ON oi.seller_id = ds.seller_nk
        GROUP BY
            1, 2, 3
    ),

    final_fct_orders AS (
        SELECT
            o.order_id AS dd_order_id,
            ao.product_id,
            dc.customer_id,
            ao.seller_id,
            os.order_status_id,
            dd.date_id AS order_date,
            ao.total_quantity,
            ao.total_price,
            ao.total_freight,
            (ao.total_price + ao.total_freight) AS total_amount

        FROM
            stg_orders o
        JOIN
            aggregated_order_items ao ON o.order_id = ao.order_id
        JOIN
            dim_customers dc ON o.customer_id = dc.customer_nk
        JOIN
            dim_order_status os ON o.order_status = os.order_status
        JOIN
            dim_date dd ON TO_DATE(o.order_purchase_timestamp, 'YYYY-MM-DD') = dd.date_actual
    )

INSERT INTO final.fct_orders(
    -- order_id,
    dd_order_id,
    product_id,
    customer_id,
    seller_id,
    order_status_id,
    order_date,
    total_quantity,
    total_price,
    total_freight,
    total_amount
)

SELECT
    dd_order_id,
    product_id,
    customer_id,
    seller_id,
    order_status_id,
    order_date,
    total_quantity,
    total_price,
    total_freight,
    total_amount

FROM final_fct_orders
 
ON CONFLICT(order_id, dd_order_id, product_id, customer_id, seller_id, order_status_id, order_date)
DO UPDATE SET
    total_quantity = EXCLUDED.total_quantity,
    total_price = EXCLUDED.total_price,
    total_freight = EXCLUDED.total_freight,
    total_amount = EXCLUDED.total_amount,
    updated_at = CASE WHEN
                        final.fct_orders.total_quantity <> EXCLUDED.total_quantity
                        OR final.fct_orders.total_price <> EXCLUDED.total_price
                        OR final.fct_orders.total_freight <> EXCLUDED.total_freight
                        OR final.fct_orders.total_amount <> EXCLUDED.total_amount
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        final.fct_orders.updated_at
                END;