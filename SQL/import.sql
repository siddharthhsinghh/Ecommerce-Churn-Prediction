CREATE DATABASE IF NOT EXISTS churn;
USE churn;

-- 1. Customers
CREATE TABLE IF NOT EXISTS olist_customers_dataset (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

-- 2. Geolocation
CREATE TABLE IF NOT EXISTS olist_geolocation_dataset (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10, 7),
    geolocation_lng DECIMAL(10, 7),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

-- 3. Order Items
CREATE TABLE IF NOT EXISTS olist_order_items_dataset (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2)
);

-- 4. Order Payments
CREATE TABLE IF NOT EXISTS olist_order_payments_dataset (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10, 2)
);

-- 5. Order Reviews
CREATE TABLE IF NOT EXISTS olist_order_reviews_dataset (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

-- 6. Orders
CREATE TABLE IF NOT EXISTS olist_orders_dataset (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

-- 7. Products
CREATE TABLE IF NOT EXISTS olist_products_dataset (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- 8. Sellers
CREATE TABLE IF NOT EXISTS olist_sellers_dataset (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

-- 9. Product Category Translation
CREATE TABLE IF NOT EXISTS product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

SHOW TABLES;

SHOW GLOBAL VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

USE churn;

TRUNCATE TABLE olist_customers_dataset;
TRUNCATE TABLE olist_geolocation_dataset;
TRUNCATE TABLE olist_order_items_dataset;
TRUNCATE TABLE olist_order_payments_dataset;
TRUNCATE TABLE olist_order_reviews_dataset;
TRUNCATE TABLE olist_orders_dataset;
TRUNCATE TABLE olist_products_dataset;
TRUNCATE TABLE olist_sellers_dataset;
TRUNCATE TABLE product_category_name_translation;

-- 1. Customers
LOAD DATA LOCAL INFILE 'C:/Users/siddh/OneDrive/Desktop/Churn/Dataset/olist_customers_dataset.csv'
INTO TABLE olist_customers_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 2. Geolocation
LOAD DATA LOCAL INFILE 'C:/Users/siddh/OneDrive/Desktop/Churn/Dataset/olist_geolocation_dataset.csv'
INTO TABLE olist_geolocation_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3. Order Items
LOAD DATA LOCAL INFILE 'C:/Users/siddh/OneDrive/Desktop/Churn/Dataset/olist_order_items_dataset.csv'
INTO TABLE olist_order_items_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 4. Order Payments
LOAD DATA LOCAL INFILE 'C:/Users/siddh/OneDrive/Desktop/Churn/Dataset/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 5. Order Reviews
LOAD DATA LOCAL INFILE 'C:/Users/siddh/OneDrive/Desktop/Churn/Dataset/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 6. Orders
LOAD DATA LOCAL INFILE 'C:/Users/siddh/OneDrive/Desktop/Churn/Dataset/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 7. Products
LOAD DATA LOCAL INFILE 'C:/Users/siddh/OneDrive/Desktop/Churn/Dataset/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 8. Sellers
LOAD DATA LOCAL INFILE 'C:/Users/siddh/OneDrive/Desktop/Churn/Dataset/olist_sellers_dataset.csv'
INTO TABLE olist_sellers_dataset
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 9. Product Category Translation
LOAD DATA LOCAL INFILE 'C:/Users/siddh/OneDrive/Desktop/Churn/Dataset/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

USE churn;

SELECT 'customers' AS dataset, COUNT(*) AS total_rows
FROM olist_customers_dataset

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM olist_geolocation_dataset

UNION ALL

SELECT 'order_items', COUNT(*)
FROM olist_order_items_dataset

UNION ALL

SELECT 'order_payments', COUNT(*)
FROM olist_order_payments_dataset

UNION ALL

SELECT 'order_reviews', COUNT(*)
FROM olist_order_reviews_dataset

UNION ALL

SELECT 'orders', COUNT(*)
FROM olist_orders_dataset

UNION ALL

SELECT 'products', COUNT(*)
FROM olist_products_dataset

UNION ALL

SELECT 'sellers', COUNT(*)
FROM olist_sellers_dataset

UNION ALL

SELECT 'category_translation', COUNT(*)
FROM product_category_name_translation;