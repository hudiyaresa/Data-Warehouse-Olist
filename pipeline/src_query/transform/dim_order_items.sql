MERGE INTO final.dim_order_items AS final
USING staging.order_items AS staging
ON final.order_item_id = staging.order_item_id

WHEN MATCHED THEN
    UPDATE SET
        price = staging.price,
        freight_value = staging.freight_value,
        order_nk = staging.order_id,
        product_id = staging.product_id,
        seller_nk = staging.seller_id,
        shipping_limit_date = staging.shipping_limit_date,
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
        staging.order_item_id, 
        staging.price, 
        staging.freight_value, 
        staging.order_id, 
        staging.product_id, 
        staging.seller_id, 
        staging.shipping_limit_date, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP
    );
