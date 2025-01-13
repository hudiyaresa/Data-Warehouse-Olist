INSERT INTO stg.sellers
    (seller_id, seller_zip_code_prefix, latitude, longitude, seller_city, seller_state)
    
SELECT
    s.seller_id,
    s.seller_zip_code_prefix,
    g.geolocation_lat as latitude,
    g.geolocation_lng as longitude,
    s.seller_city,
    s.seller_state

FROM public.sellers s

JOIN public.geolocation g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix

ON CONFLICT(seller_id)
DO UPDATE SET
    seller_zip_code_prefix = EXCLUDED.seller_zip_code_prefix,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    seller_city = EXCLUDED.seller_city,
    seller_state = EXCLUDED.seller_state,

    updated_at = CASE WHEN
                        stg.sellers.seller_zip_code_prefix <> EXCLUDED.seller_zip_code_prefix
                        OR stg.sellers.latitude <> EXCLUDED.latitude 
                        OR stg.sellers.longitude <> EXCLUDED.longitude 
                        OR stg.sellers.seller_city <> EXCLUDED.seller_city
                        OR stg.sellers.seller_state <> EXCLUDED.seller_state
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        stg.sellers.updated_at
                END;
