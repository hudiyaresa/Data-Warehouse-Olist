INSERT INTO stg.customers 
    (customer_id, customer_unique_id, customer_zip_code_prefix, latitude, longitude, customer_city, customer_state)

SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    g.geolocation_lat as latitude,
    g.geolocation_lng as longitude,
    c.customer_city,
    c.customer_state

FROM public.customers c

JOIN public.geolocation g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix

ON CONFLICT(customer_id) 
DO UPDATE SET
    customer_unique_id = EXCLUDED.customer_unique_id,
    customer_zip_code_prefix = EXCLUDED.customer_zip_code_prefix,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    customer_city = EXCLUDED.customer_city,
    customer_state = EXCLUDED.customer_state,

    updated_at = CASE WHEN 
                        stg.customers.customer_unique_id <> EXCLUDED.customer_unique_id 
                        OR stg.customers.customer_zip_code_prefix <> EXCLUDED.customer_zip_code_prefix 
                        OR stg.customers.latitude <> EXCLUDED.latitude 
                        OR stg.customers.longitude <> EXCLUDED.longitude 
                        OR stg.customers.customer_city <> EXCLUDED.customer_city 
                        OR stg.customers.customer_state <> EXCLUDED.customer_state 
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        stg.customers.updated_at
                END;