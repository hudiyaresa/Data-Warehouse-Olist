INSERT INTO stg.products
    (product_id, product_category_name, product_category_name_english, product_name_lenght, product_description_lenght,
     product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
     
SELECT
    p.product_id,
    p.product_category_name,
    pcat.product_category_name_english, 
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm

FROM public.products p

LEFT JOIN public.product_category_name_translation pcat
    ON p.product_category_name = pcat.product_category_name

ON CONFLICT(product_id)
DO UPDATE SET
    product_category_name = EXCLUDED.product_category_name,
    product_category_name_english = EXCLUDED.product_category_name_english,
    product_name_lenght = EXCLUDED.product_name_lenght,
    product_description_lenght = EXCLUDED.product_description_lenght,
    product_photos_qty = EXCLUDED.product_photos_qty,
    product_weight_g = EXCLUDED.product_weight_g,
    product_length_cm = EXCLUDED.product_length_cm,
    product_height_cm = EXCLUDED.product_height_cm,
    product_width_cm = EXCLUDED.product_width_cm,

    updated_at = CASE WHEN 
                        stg.products.product_category_name <> EXCLUDED.product_category_name
                        OR stg.products.product_category_name_english <> EXCLUDED.product_category_name_english
                        OR stg.products.product_name_lenght <> EXCLUDED.product_name_lenght
                        OR stg.products.product_description_lenght <> EXCLUDED.product_description_lenght
                        OR stg.products.product_photos_qty <> EXCLUDED.product_photos_qty
                        OR stg.products.product_weight_g <> EXCLUDED.product_weight_g
                        OR stg.products.product_length_cm <> EXCLUDED.product_length_cm
                        OR stg.products.product_height_cm <> EXCLUDED.product_height_cm
                        OR stg.products.product_width_cm <> EXCLUDED.product_width_cm
                THEN
                        CURRENT_TIMESTAMP  
                ELSE
                        stg.products.updated_at
                END;
