MERGE INTO stg.products AS staging
USING (
    SELECT product_id, 
    product_category_name, 
    product_category_name_english, 
    product_weight_g, 
    product_length_cm, 
    product_height_cm, 
    product_width_cm
    FROM public.products
) source

ON staging.product_id = source.product_id

WHEN MATCHED AND (
    staging.product_category_name <> source.product_category_name
    OR staging.product_category_name_english <> source.product_category_name_english

) THEN
    UPDATE SET current_flag = "Expired", 
    updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED BY SOURCE OR staging.current_flag = 'Expired' THEN
    INSERT (
        product_id, 
        product_category_name, 
        product_category_name_english, 
        product_weight_g, 
        product_length_cm, 
        product_height_cm, 
        product_width_cm,
        created_at, 
        updated_at, 
        current_flag
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
        CURRENT_TIMESTAMP, 
        "Current"
    );
