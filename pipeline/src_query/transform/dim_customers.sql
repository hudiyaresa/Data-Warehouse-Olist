MERGE INTO final.dim_customers AS final
USING (
    SELECT 
        customer_id AS customer_nk,
        customer_unique_id,
        customer_zip_code_prefix,
        latitude,
        longitude,
        customer_city,
        customer_state,
        CURRENT_TIMESTAMP AS created_at
    FROM stg.customers
) AS staging

ON final.customer_nk = staging.customer_nk

WHEN MATCHED AND (
    final.customer_zip_code_prefix <> staging.customer_zip_code_prefix OR
    final.customer_city <> staging.customer_city OR
    final.customer_state <> staging.customer_state
) THEN
    UPDATE SET 
        current_flag = 'Expired',
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        customer_id, 
        customer_nk, 
        customer_unique_id, 
        customer_zip_code_prefix, 
        latitude, 
        longitude,        
        customer_city, 
        customer_state, 
        created_at, 
        updated_at, 
        current_flag
    )
    VALUES (
        gen_random_uuid(),
        staging.customer_nk, 
        staging.customer_unique_id, 
        staging.customer_zip_code_prefix, 
        staging.latitude, 
        staging.longitude,
        staging.customer_city, 
        staging.customer_state, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP, 
        'Current'
    );
