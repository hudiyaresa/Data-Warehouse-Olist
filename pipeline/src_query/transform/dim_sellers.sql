MERGE INTO final.dim_sellers AS final
USING (
    SELECT 
        seller_id AS seller_nk,
        seller_zip_code_prefix,
        latitude,
        longitude,
        seller_city,
        seller_state,
        CURRENT_TIMESTAMP AS created_at
    FROM staging.sellers
) AS 

ON final.seller_nk = staging.seller_nk

WHEN MATCHED AND (
    final.seller_zip_code_prefix <> staging.seller_zip_code_prefix OR
    final.seller_city <> staging.seller_city OR
    final.seller_state <> staging.seller_state
) THEN
    UPDATE SET 
        current_flag = 'Expired',
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        seller_id, 
        seller_nk, 
        seller_zip_code_prefix,
        latitude, 
        longitude,   
        seller_city, 
        seller_state, 
        created_at, 
        updated_at, 
        current_flag
    )
    VALUES (
        gen_random_uuid(),
        staging.seller_id, 
        staging.seller_zip_code_prefix,
        staging.latitude, 
        staging.longitude,   
        staging.seller_city, 
        staging.seller_state, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP, 
        'Current'
    );
