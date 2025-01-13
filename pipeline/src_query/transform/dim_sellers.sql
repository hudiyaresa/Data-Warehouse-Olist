MERGE INTO final.dim_sellers AS final
USING (
    SELECT 
        seller_id AS seller_nk,
        seller_zip_code_prefix,
        -- latitude,
        -- longitude,
        seller_city,
        seller_state,
        CURRENT_TIMESTAMP AS created_at
    FROM stg.sellers
) AS 

ON final.seller_nk = stg.seller_nk

WHEN MATCHED AND (
    -- final.seller_zip_code_prefix <> stg.seller_zip_code_prefix OR
    final.seller_city <> stg.seller_city OR
    final.seller_state <> stg.seller_state
) THEN
    UPDATE SET 
        current_flag = 'Expired',
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        seller_id, 
        seller_nk, 
        seller_zip_code_prefix,
        -- latitude, 
        -- longitude,   
        seller_city, 
        seller_state, 
        created_at, 
        updated_at, 
        current_flag
    )
    VALUES (
        gen_random_uuid(),
        stg.seller_id, 
        stg.seller_zip_code_prefix,
        -- stg.latitude, 
        -- stg.longitude,   
        stg.seller_city, 
        stg.seller_state, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP, 
        'Current'
    );
