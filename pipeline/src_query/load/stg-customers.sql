MERGE INTO stg.customers AS staging
USING (
    SELECT 
        c.customer_id,
        c.customer_zip_code_prefix,
        g.geolocation_lat,
        g.geolocation_lng,
        c.customer_city,
        c.customer_state,
        CURRENT_TIMESTAMP AS created_at
    FROM public.customers c
    JOIN public.geolocation g
        ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
) AS source


ON staging.customer_id = source.customer_id

WHEN MATCHED AND (
    staging.customer_city <> source.customer_city OR 
    staging.customer_state <> source.customer_state OR 
    staging.customer_zip_code_prefix <> source.customer_zip_code_prefix
) THEN
    UPDATE SET 
        current_flag = 'Expired',
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        customer_id, 
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
        source.customer_id, 
        source.customer_zip_code_prefix, 
        source.geolocation_lat, 
        source.geolocation_lng,
        source.customer_city, 
        source.customer_state, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP, 
        'Current'
    );
