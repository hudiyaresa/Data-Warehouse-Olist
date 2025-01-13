MERGE INTO final.dim_order_items AS final
USING stg.order_items AS stg
ON final.order_item_id = stg.order_item_id

WHEN MATCHED THEN
    UPDATE SET
        price = stg.price,
        freight_value = stg.freight_value,
        order_nk = stg.order_id,
        product_id = stg.product_id,
        seller_nk = stg.seller_id,
        shipping_limit_date = stg.shipping_limit_date::timestamp,
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        order_item_id, 
        order_item_nk, 
        price, 
        freight_value, 
        order_nk, 
        product_id, 
        seller_nk, 
        shipping_limit_date, 
        created_at, 
        updated_at
    )
    VALUES (
        gen_random_uuid(), 
        stg.order_item_id, 
        stg.price, 
        stg.freight_value, 
        stg.order_id, 
        stg.product_id, 
        stg.seller_id, 
        stg.shipping_limit_date::timestamp, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP
    );
