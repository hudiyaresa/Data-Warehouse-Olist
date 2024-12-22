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

    dim_date AS (
        SELECT *
        FROM final.dim_date
    ),

    dim_order_reviews AS (
        SELECT *
        FROM final.dim_order_reviews
    ),

    final_fct_customer_review_delivered_products AS (
        SELECT
            dc.customer_id,
            dp.product_id,
            ds.seller_id,
            dd.date_id,
            dor.review_id,
            dor.review_score,
            dor.review_comment_title,
            dor.review_comment_message,
            CASE 
                WHEN do.shipping_limit_date >= do.order_delivered_customer_date THEN 'On Time'
                ELSE 'Late'
            END AS on_time_delivery_status,
            EXTRACT(DAY FROM (do.order_delivered_customer_date - do.shipping_limit_date)) AS total_days_delay_delivery
        FROM final.stg_order_reviews dor
        JOIN dim_customers dc ON dc.customer_id = dor.customer_id
        JOIN dim_products dp ON dp.product_id = dor.product_id
        JOIN dim_sellers ds ON ds.seller_id = dp.seller_id
        JOIN dim_date dd ON dd.date = DATE(dor.review_creation_date)
    )

INSERT INTO final.fct_Customer_Review_Delivered_Products (
    customer_id, 
    product_id, 
    seller_id, 
    date_id, 
    review_id,
    review_score, 
    review_comment_title, 
    review_comment_message,
    on_time_delivery_status, 
    total_days_delay_delivery
)
SELECT * FROM final_fct_customer_review_delivered_producs
ON CONFLICT (customer_id, product_id, review_id)
DO UPDATE SET
    review_score = EXCLUDED.review_score,
    review_comment_title = EXCLUDED.review_comment_title,
    review_comment_message = EXCLUDED.review_comment_message,
    on_time_delivery_status = EXCLUDED.on_time_delivery_status,
    total_days_delay_delivery = EXCLUDED.total_days_delay_delivery;
