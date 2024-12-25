MERGE INTO stg.geolocation AS staging
USING public.geolocation AS source
ON staging.geolocation_zip_code_prefix = source.geolocation_zip_code_prefix

WHEN MATCHED THEN
    UPDATE SET
        geolocation_lat = source.geolocation_lat,
        geolocation_lng = source.geolocation_lng,
        geolocation_city = source.geolocation_city,
        geolocation_state = source.geolocation_state,
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        geolocation_zip_code_prefix,
        geolocation_lat, 
        geolocation_lng, 
        geolocation_city, 
        geolocation_state, 
        created_at, 
        updated_at
    )
    VALUES (
        source.geolocation_zip_code_prefix,
        source.geolocation_lat, 
        source.geolocation_lng,
        source.geolocation_city, 
        source.geolocation_state, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP
    );
