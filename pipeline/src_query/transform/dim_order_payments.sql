MERGE INTO final.dim_order_payments AS final
USING (
    SELECT 
        payment_sequential,
        payment_installments,
        payment_value,
        order_id,
        payment_type,
        CURRENT_TIMESTAMP AS created_at
    FROM stg.order_payments
) AS stg

ON final.payment_sequential_id = stg.payment_sequential_id
    AND final.order_nk = stg.order_id

WHEN MATCHED AND (
    final.payment_installments <> stg.payment_installments OR
    final.payment_value <> stg.payment_value OR
    final.payment_type <> stg.payment_type
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
        order_nk, 
        payment_type, 
        created_at, 
        updated_at, 
        current_flag
    )
    VALUES (
        gen_random_uuid(), 
        stg.payment_sequential, 
        stg.payment_installments, 
        stg.payment_value, 
        stg.order_id, 
        stg.payment_type, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP, 
        'Current'
    );
