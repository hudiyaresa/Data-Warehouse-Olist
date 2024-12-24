MERGE INTO stg.orders_dim AS staging
USING (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        CURRENT_TIMESTAMP AS created_at
    FROM public.orders o
) AS source


ON staging.order_id = source.order_id

WHEN MATCHED AND (
    staging.order_status <> source.order_status OR 
    staging.order_purchase_timestamp <> source.order_purchase_timestamp
) THEN
    UPDATE SET 
        current_flag = 'Expired',
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED BY SOURCE THEN
    INSERT (
        order_id, 
        customer_id, 
        order_status, 
        order_purchase_timestamp,
        created_at, 
        updated_at, 
        current_flag
    )
    VALUES (
        source.order_id, 
        source.customer_id, 
        source.order_status, 
        source.order_purchase_timestamp,
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP, 
        'Current'
    );
