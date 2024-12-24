MERGE INTO stg.order_reviews AS staging
USING public.order_reviews AS source
ON staging.review_id = source.review_id AND staging.order_id = source.order_id

WHEN MATCHED THEN
    UPDATE SET
        review_score = source.review_score,
        review_comment_title = source.review_comment_title,
        review_comment_message = source.review_comment_message,
        updated_at = CURRENT_TIMESTAMP

WHEN NOT MATCHED THEN
    INSERT (
        review_id, 
        order_id, 
        review_score, 
        review_comment_title, 
        review_comment_message, 
        review_creation_date, 
        created_at, 
        updated_at
    )
    VALUES (
        source.review_id, 
        source.order_id, 
        source.review_score, 
        source.review_comment_title, 
        source.review_comment_message,
        source.review_creation_date, 
        CURRENT_TIMESTAMP, 
        CURRENT_TIMESTAMP
    );
