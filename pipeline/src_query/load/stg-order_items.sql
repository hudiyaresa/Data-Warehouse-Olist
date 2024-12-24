MERGE INTO stg.order_items AS staging
USING public.order_items AS source
ON staging.order_id = source.order_id AND staging.order_item_id = source.order_item_id

WHEN MATCHED THEN
    UPDATE SET
        seller_id = source.seller_id,
        shipping_limit_date = source.shipping_limit_date,
        price = source.price,
        freight_value = source.freight_value,
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        order_id,
        order_item_id, 
        product_id, 
        seller_id, 
        shipping_limit_date, 
        price, freight_value, 
        created_at, 
        updated_at
    )
    VALUES (
        source.order_id,
        source.order_item_id, 
        source.product_id, 
        source.seller_id, 
        source.shipping_limit_date,
        source.price, 
        source.freight_value, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP
    );
