MERGE INTO stg.product_category_name AS staging
USING public.product_category_name AS source
ON staging.product_category_name = source.product_category_name

WHEN MATCHED THEN
    UPDATE SET
        product_category_name_english = source.product_category_name_english,
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        product_category_name,
        product_category_name_english, 
        created_at, 
        updated_at
    )
    VALUES (
        source.product_category_name,
        source.product_category_name_english, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP
    );
