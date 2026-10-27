-- INSPECT TABLE STRUCTURES
DESCRIBE olist_customers_dataset;
DESCRIBE olist_orders_dataset;
DESCRIBE olist_order_items_dataset;
DESCRIBE olist_order_payments_dataset;
DESCRIBE olist_order_reviews_dataset;
DESCRIBE olist_products_dataset;
DESCRIBE olist_sellers_dataset;
DESCRIBE olist_geolocation_dataset;
DESCRIBE product_category_name_translation;

-- PREVIEW CUSTOMER DATA
SELECT *
FROM olist_customers_dataset
LIMIT 10;

--  CHECK ORDER STATUS DISTRIBUTION
SELECT order_status,COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;

-- CHECK CUSTOMER DISTRIBUTION BY STATE
SELECT customer_state, COUNT(*) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY total_customers DESC;

-- CHECK PRODUCT CATEGORY DISTRIBUTION
SELECT product_category_name, COUNT(*) AS total_products
FROM olist_products_dataset
GROUP BY product_category_name
ORDER BY total_products DESC
LIMIT 15;

-- CHECK REVIEW SCORE DISTRIBUTION
SELECT review_score,COUNT(*) AS total_reviews
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;

-- CHECK ORDER DATE RANGE
SELECT MIN(order_purchase_timestamp) AS first_order_date,MAX(order_purchase_timestamp) AS last_order_date
FROM olist_orders_dataset;

-- CHECK MISSING CUSTOMER VALUES
SELECT SUM(customer_id IS NULL) AS missing_customer_ids,
SUM(customer_unique_id IS NULL) AS missing_unique_ids,
SUM(customer_city IS NULL) AS missing_cities,
SUM(customer_state IS NULL) AS missing_states
FROM olist_customers_dataset;

-- CHECK MISSING ORDER VALUES
SELECT SUM(order_id is NULL) AS missing_order_id,
SUM(customer_id IS NULL) AS missing_customer_id,
SUM(order_status is NULL) as missing_status,
SUM(order_purchase_timestamp is NULL) AS missing_purchase_dates
FROM olist_orders_dataset;

-- CHECK DUPLICATE ORDER RECORDS
SELECT order_id, COUNT(*) AS occurences
FROM olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY occurences DESC;

-- CHECK DUPLICATE CUSTOMER RECORDS
SELECT customer_id,COUNT(*) AS occurrences
FROM olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC