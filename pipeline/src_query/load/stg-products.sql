MERGE INTO stg.products AS staging
USING (
    SELECT p.product_id, 
        p.product_category_name, 
        pcat.product_category_name_english, 
        p.product_weight_g, 
        p.product_length_cm, 
        p.product_height_cm, 
        p.product_width_cm
    FROM public.products p
    LEFT JOIN public.product_category_name_translation pcat
        ON p.product_category_name = pcat.product_category_name
) source

ON staging.product_id = source.product_id

WHEN MATCHED AND (
    staging.product_category_name <> source.product_category_name
    OR staging.product_category_name_english <> source.product_category_name_english
    OR staging.product_weight_g <> source.product_weight_g
    OR staging.product_length_cm <> source.product_length_cm
    OR staging.product_height_cm <> source.product_height_cm
    OR staging.product_width_cm <> source.product_width_cm
) THEN
    UPDATE SET 
        staging.product_category_name = source.product_category_name,
        staging.product_category_name_english = source.product_category_name_english,
        staging.product_weight_g = source.product_weight_g,
        staging.product_length_cm = source.product_length_cm,
        staging.product_height_cm = source.product_height_cm,
        staging.product_width_cm = source.product_width_cm,
        staging.updated_at = CURRENT_TIMESTAMP

-- When not matched, insert new record
WHEN NOT MATCHED THEN
    INSERT (
        product_id, 
        product_category_name, 
        product_category_name_english, 
        product_weight_g, 
        product_length_cm, 
        product_height_cm, 
        product_width_cm,
        created_at, 
        updated_at
    )
    VALUES (
        source.product_id, 
        source.product_category_name, 
        source.product_category_name_english,
        source.product_weight_g, 
        source.product_length_cm, 
        source.product_height_cm,
        source.product_width_cm, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP
    );
