MERGE INTO final.dim_products AS final
USING staging.products AS staging
ON final.product_id = staging.product_id

WHEN MATCHED THEN
    UPDATE SET
        product_name_lenght = staging.product_name_lenght,
        product_description_lenght = staging.product_description_lenght,
        product_photos_qty = staging.product_photos_qty,
        product_weight_g = staging.product_weight_g,
        product_length_cm = staging.product_length_cm,
        product_height_cm = staging.product_height_cm,
        product_width_cm = staging.product_width_cm,
        product_category_name = staging.product_category_name,
        product_category_name_english = staging.product_category_name_english,
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
        staging.product_id, 
        staging.product_name_lenght, 
        staging.product_description_lenght, 
        staging.product_photos_qty, 
        staging.product_weight_g, 
        staging.product_length_cm, 
        staging.product_height_cm, 
        staging.product_width_cm, 
        staging.product_category_name, 
        staging.product_category_name_english, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP
    );
