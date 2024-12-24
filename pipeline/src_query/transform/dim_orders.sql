MERGE INTO stg.orders_dim AS final
USING (
    SELECT 
        order_id AS order_nk,
        customer_id,
        order_status,
        order_purchase_timestamp,
        CURRENT_TIMESTAMP AS created_at
    FROM stg.orders
) AS staging

ON final.order_nk = staging.order_nk

WHEN MATCHED AND (
    final.order_status <> staging.order_status OR 
    final.order_purchase_timestamp <> staging.order_purchase_timestamp
) THEN
    UPDATE SET 
        current_flag = 'Expired',
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED BY SOURCE THEN
    INSERT (
        order_id, 
        order_nk, 
        customer_id, 
        order_status, 
        order_purchase_timestamp,
        created_at, 
        updated_at, 
        current_flag
    )
    VALUES (
        gen_random_uuid(),
        staging.order_id, 
        staging.customer_id, 
        staging.order_status, 
        staging.order_purchase_timestamp,
        staging.created_at, 
        CURRENT_TIMESTAMP, 
        'Current'
    );
