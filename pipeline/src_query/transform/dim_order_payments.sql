MERGE INTO final.dim_order_payments AS final
USING (
    SELECT 
        payment_sequential,
        payment_installments,
        payment_value,
        order_id,
        payment_type,
        CURRENT_TIMESTAMP AS created_at
    FROM staging.order_payments
) AS staging

ON final.payment_sequential_id = staging.payment_sequential_id
    AND final.order_id = staging.order_id

WHEN MATCHED AND (
    final.payment_installments <> staging.payment_installments OR
    final.payment_value <> staging.payment_value OR
    final.payment_type <> staging.payment_type
) THEN
    UPDATE SET 
        current_flag = 'Expired',
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        payment_method_id, 
        payment_sequential, 
        payment_installments, 
        payment_value, 
        order_id, 
        payment_type, 
        created_at, 
        updated_at, 
        current_flag
    )
    VALUES (
        gen_random_uuid(), 
        staging.payment_sequential, 
        staging.payment_installments, 
        staging.payment_value, 
        staging.order_id, 
        staging.payment_type, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP, 
        'Current'
    );
