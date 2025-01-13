MERGE INTO final.dim_products AS final
USING stg.products AS stg
ON final.product_id = stg.product_id

WHEN MATCHED THEN
    UPDATE SET
        product_name_lenght = stg.product_name_lenght,
        product_description_lenght = stg.product_description_lenght,
        product_photos_qty = stg.product_photos_qty,
        product_weight_g = stg.product_weight_g,
        product_length_cm = stg.product_length_cm,
        product_height_cm = stg.product_height_cm,
        product_width_cm = stg.product_width_cm,
        product_category_name = stg.product_category_name,
        product_category_name_english = stg.product_category_name_english,
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        product_id, 
        product_name_lenght, 
        product_description_lenght, 
        product_photos_qty, 
        product_weight_g, 
        product_length_cm, 
        product_height_cm, 
        product_width_cm, 
        product_category_name, 
        product_category_name_english, 
        created_at, 
        updated_at
    )
    VALUES (
        stg.product_id, 
        stg.product_name_lenght, 
        stg.product_description_lenght, 
        stg.product_photos_qty, 
        stg.product_weight_g, 
        stg.product_length_cm, 
        stg.product_height_cm, 
        stg.product_width_cm, 
        stg.product_category_name, 
        stg.product_category_name_english, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP
    );
