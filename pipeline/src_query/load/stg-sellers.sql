MERGE INTO stg.sellers_dim AS staging
USING (
    SELECT 
        s.seller_id,
        s.seller_zip_code_prefix,
        g.geolocation_lat,
        g.geolocation_lng,
        s.seller_city,
        s.seller_state,
        CURRENT_TIMESTAMP AS created_at
    FROM public.sellers s
    JOIN public.geolocation g
        ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
) AS source


ON staging.seller_id = source.seller_id

WHEN MATCHED AND (
    staging.seller_city <> source.seller_city OR 
    staging.seller_state <> source.seller_state OR 
    staging.seller_zip_code_prefix <> source.seller_zip_code_prefix
) THEN
    UPDATE SET 
        current_flag = 'Expired',
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED BY SOURCE THEN
    INSERT (
        seller_id, 
        seller_zip_code_prefix, 
        geolocation_lat, 
        geolocation_long,
        seller_city, 
        seller_state, 
        created_at, 
        updated_at, 
        current_flag
    )
    VALUES (
        source.seller_id, 
        source.seller_zip_code_prefix, 
        source.geolocation_lat, 
        source.geolocation_lng,
        source.seller_city, 
        source.seller_state, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP, 
        'Current'
    );
