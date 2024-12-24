MERGE INTO stg.order_payments AS staging
USING (
    SELECT 
        op.order_id,
        op.payment_sequential,
        op.payment_type,
        op.payment_installments,
        op.payment_value,
        CURRENT_TIMESTAMP AS created_at
    FROM public.order_payments op
) AS source

-- check similarity of composite key
ON staging.order_id = source.order_id 
   AND staging.payment_sequential = source.payment_sequential

WHEN MATCHED AND (
    staging.payment_type <> source.payment_type OR
    staging.payment_installments <> source.payment_installments OR
    staging.payment_value <> source.payment_value
) THEN
    UPDATE SET 
        current_flag = 'Expired',
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        order_id, 
        payment_sequential, 
        payment_type, 
        payment_installments,
        payment_value, 
        created_at, 
        updated_at, 
        current_flag
    )
    VALUES (
        source.order_id, 
        source.payment_sequential, 
        source.payment_type,
        source.payment_installments, 
        source.payment_value, 
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP, 
        'Current'
    );
