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
    FROM staging.order_reviews
) AS staging

ON final.review_nk = staging.review_nk
    AND final.order_id = staging.order_id

WHEN MATCHED THEN
    UPDATE SET
        review_score = staging.review_score,
        order_id = staging.order_id,
        review_comment_title = staging.review_comment_title,
        review_comment_message = staging.review_comment_message,
        review_creation_date = staging.review_creation_date,
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
        staging.review_nk, 
        staging.review_score, 
        staging.order_id, 
        staging.review_comment_title, 
        staging.review_comment_message, 
        staging.review_creation_date, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP
    );
