USE churn;

SELECT
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date,
    COUNT(*) AS total_orders
FROM olist_orders_dataset;

SELECT
    COUNT(DISTINCT c.customer_unique_id) AS historical_customers,
    COUNT(DISTINCT o.order_id) AS historical_orders
FROM olist_orders_dataset AS o
JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
WHERE o.order_purchase_timestamp < '2018-04-01';


SELECT c.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_purchase_date,
    MAX(o.order_purchase_timestamp) AS last_purchase_date,
    DATEDIFF('2018-04-01',DATE(MAX(o.order_purchase_timestamp))) AS recency,
    COUNT(DISTINCT o.order_id) AS frequency,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id),2) AS avg_order_value,
    DATEDIFF(DATE(MAX(o.order_purchase_timestamp)),DATE(MIN(o.order_purchase_timestamp))) AS customer_tenure
FROM olist_orders_dataset AS o
JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp < '2018-04-01'
GROUP BY c.customer_unique_id
ORDER BY avg_order_value DESC;

SELECT c.customer_unique_id,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM olist_orders_dataset AS o
JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
LEFT JOIN olist_order_reviews_dataset AS r
    ON o.order_id = r.order_id
WHERE o.order_purchase_timestamp < '2018-04-01'
GROUP BY c.customer_unique_id
ORDER BY total_reviews DESC;

CREATE TABLE IF NOT EXISTS customer_churn_dataset AS
WITH customer_features AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date,
        MAX(o.order_purchase_timestamp) AS last_purchase_date,
        DATEDIFF('2018-04-01',
		DATE(MAX(o.order_purchase_timestamp))) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        COALESCE(ROUND(SUM(oi.price), 2), 0) AS monetary,
        ROUND(COALESCE(SUM(oi.price), 0) /COUNT(DISTINCT o.order_id),2) AS avg_order_value,
        DATEDIFF(
            DATE(MAX(o.order_purchase_timestamp)),
            DATE(MIN(o.order_purchase_timestamp))
        ) AS customer_tenure
    FROM olist_orders_dataset AS o
    JOIN olist_customers_dataset AS c
        ON o.customer_id = c.customer_id
    LEFT JOIN olist_order_items_dataset AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_purchase_timestamp < '2018-04-01'
    GROUP BY c.customer_unique_id
),
customer_reviews AS (
    SELECT
        c.customer_unique_id,
        COUNT(r.review_id) AS total_reviews,
        ROUND(AVG(r.review_score), 2) AS avg_review_score
    FROM olist_orders_dataset AS o
    JOIN olist_customers_dataset AS c
        ON o.customer_id = c.customer_id
    LEFT JOIN olist_order_reviews_dataset AS r
        ON o.order_id = r.order_id
    WHERE o.order_purchase_timestamp < '2018-04-01'
    GROUP BY c.customer_unique_id
),
future_activity AS (
    SELECT DISTINCT
        c.customer_unique_id
    FROM olist_orders_dataset AS o
    JOIN olist_customers_dataset AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_purchase_timestamp >= '2018-04-01'
      AND o.order_purchase_timestamp < '2018-09-28'
)
SELECT
    cf.*,
    cr.total_reviews,
    cr.avg_review_score,
    CASE
        WHEN fa.customer_unique_id IS NOT NULL THEN 0
        ELSE 1
    END AS churn
FROM customer_features AS cf
LEFT JOIN customer_reviews AS cr
    ON cf.customer_unique_id = cr.customer_unique_id
LEFT JOIN future_activity AS fa
    ON cf.customer_unique_id = fa.customer_unique_id
ORDER BY cf.monetary DESC;

SELECT COUNT(*) AS total_customers
FROM customer_churn_dataset;

SELECT
    churn,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM customer_churn_dataset
GROUP BY churn;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customer_churn_dataset;

SELECT
    COUNT(*) AS zero_monetary_customers
FROM customer_churn_dataset
WHERE monetary = 0;

SELECT
    COUNT(DISTINCT c.customer_unique_id) AS customers_without_items,
    COUNT(DISTINCT o.order_id) AS orders_without_items
FROM olist_orders_dataset AS o

JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id

LEFT JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id

WHERE o.order_purchase_timestamp < '2018-04-01'
  AND oi.order_id IS NULL;
  
SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp
FROM olist_orders_dataset AS o

JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id

LEFT JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id

WHERE o.order_purchase_timestamp < '2018-04-01'
  AND oi.order_id IS NULL

LIMIT 10;

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS orders_without_items,
    COUNT(DISTINCT c.customer_unique_id) AS affected_customers
FROM olist_orders_dataset AS o

JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id

LEFT JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id

WHERE o.order_purchase_timestamp < '2018-04-01'
  AND oi.order_id IS NULL

GROUP BY o.order_status
ORDER BY orders_without_items DESC;

SELECT
		order_status,
		COUNT(*) AS total_orders
	FROM olist_orders_dataset
	WHERE order_purchase_timestamp < '2018-04-01'
	GROUP BY order_status
	ORDER BY total_orders DESC;
    
SELECT
    COUNT(DISTINCT o.order_id) AS eligible_orders,
    COUNT(DISTINCT c.customer_unique_id) AS eligible_customers
FROM olist_orders_dataset AS o

JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id

WHERE o.order_purchase_timestamp < '2018-04-01'

AND o.order_status NOT IN ('canceled', 'unavailable')

AND EXISTS (
    SELECT 1
    FROM olist_order_items_dataset AS oi
    WHERE oi.order_id = o.order_id
);
    
    