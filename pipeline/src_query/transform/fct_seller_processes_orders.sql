INSERT INTO final.fct_order_delivery(
    order_id,
    customer_id,
    seller_id,
    order_received_date,
    process_date,
    success_date,
    estimated_date,
    day_process,
    day_success
)

SELECT
    fo.order_id,
    dc.customer_id,
    ds.seller_id,
    oa.date_id AS order_received_date,
    op.date_id AS process_date,
    os.date_id AS success_date,
    ed.date_id AS estimated_date,

    (TO_DATE(op.date_id::text, 'YYYYMMDD') - TO_DATE(oa.date_id::text, 'YYYYMMDD')) AS day_process,
    
    (TO_DATE(os.date_id::text, 'YYYYMMDD') - TO_DATE(op.date_id::text, 'YYYYMMDD')) AS day_success

FROM
    stg.orders o
JOIN
    stg.order_items oi ON o.order_id = oi.order_id
JOIN
    final.dim_customers dc ON o.customer_id = dc.customer_nk
JOIN
    final.dim_sellers ds ON oi.seller_id = ds.seller_nk
JOIN
    final.dim_date oa ON TO_DATE(o.order_approved_at, 'YYYY-MM-DD') = oa.date_actual
JOIN
    final.dim_date op ON TO_DATE(o.order_delivered_carrier_date, 'YYYY-MM-DD') = op.date_actual
JOIN
    final.dim_date os ON TO_DATE(o.order_delivered_customer_date, 'YYYY-MM-DD') = os.date_actual
JOIN
    final.dim_date ed ON TO_DATE(o.order_estimated_delivery_date, 'YYYY-MM-DD') = ed.date_actual
JOIN
    final.fct_orders fo ON o.order_id = fo.dd_order_id
GROUP BY 
    fo.order_id,
    dc.customer_id,
    ds.seller_id,
    oa.date_id,
    op.date_id,
    os.date_id,
    ed.date_id 

ON CONFLICT(delivery_id, customer_id, seller_id, order_received_date)
DO UPDATE SET
    process_date = EXCLUDED.process_date,
    success_date = EXCLUDED.success_date,
    estimated_date = EXCLUDED.estimated_date,
    day_process = EXCLUDED.day_process,
    day_success = EXCLUDED.day_success,

    updated_at = CASE WHEN
                        final.fct_order_delivery.process_date <> EXCLUDED.process_date
                        OR final.fct_order_delivery.success_date <> EXCLUDED.success_date
                        OR final.fct_order_delivery.estimated_date <> EXCLUDED.estimated_date
                        OR final.fct_order_delivery.day_process <> EXCLUDED.day_process
                        OR final.fct_order_delivery.day_success <> EXCLUDED.day_success
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        final.fct_order_delivery.updated_at
                END;