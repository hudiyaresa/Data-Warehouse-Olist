MERGE INTO final.dim_order_reviews AS final
USING (
    SELECT 
        review_id AS review_nk,
        review_score,
        order_id,
        review_comment_title,
        review_comment_message,
        review_creation_date,
        CURRENT_TIMESTAMP AS created_at
    FROM stg.order_reviews
) AS stg

ON final.review_nk = stg.review_nk
    AND final.order_id = stg.order_id

WHEN MATCHED THEN
    UPDATE SET
        review_score = stg.review_score,
        order_id = stg.order_id,
        review_comment_title = stg.review_comment_title,
        review_comment_message = stg.review_comment_message,
        review_creation_date = stg.review_creation_date,
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        review_id, 
        review_nk, 
        review_score, 
        order_id, 
        review_comment_title, 
        review_comment_message, 
        review_creation_date, 
        created_at, 
        updated_at
    )
    VALUES (
        gen_random_uuid(), 
        stg.review_nk, 
        stg.review_score, 
        stg.order_id, 
        stg.review_comment_title, 
        stg.review_comment_message, 
        stg.review_creation_date, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP
    );
