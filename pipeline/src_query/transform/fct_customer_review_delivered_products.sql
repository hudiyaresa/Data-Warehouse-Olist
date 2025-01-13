INSERT INTO final.fct_customer_review_delivered_products(
    review_id,
    dd_review_id,
    customer_id,
    seller_id,
    product_id,
    review_date,
    review_score
)

SELECT DISTINCT
    rv.id as review_id,
    rv.review_id as dd_review_id,
    dc.customer_id,
    ds.seller_id,
    dp.product_id,
    dd.date_id as review_date,
    rv.review_score

FROM
    stg.orders o
JOIN
    stg.order_items oi ON o.order_id = oi.order_id
JOIN
    stg.order_reviews rv ON o.order_id = rv.order_id
JOIN
    final.dim_products dp ON oi.product_id = dp.product_nk
JOIN
    final.dim_customers dc ON o.customer_id = dc.customer_nk
JOIN
    final.dim_sellers ds ON oi.seller_id = ds.seller_nk
JOIN
    final.dim_date dd ON TO_DATE(rv.review_creation_date, 'YYYY-MM-DD') = dd.date_actual

-- Handle new data
ON CONFLICT(review_id, dd_review_id, customer_id, seller_id, product_id, review_date)
DO UPDATE SET
    review_score = EXCLUDED.review_score,

    -- Handle updated timestamp
    updated_at = CASE WHEN
                        final.fct_customer_review_delivered_products.review_score <> EXCLUDED.review_score
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        final.fct_customer_review_delivered_products.updated_at
                END;