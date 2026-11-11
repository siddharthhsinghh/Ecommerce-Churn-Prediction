USE churn;

-- Monthly order volume
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders
FROM olist_orders_dataset
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;

-- Average review score
SELECT
    o.order_status,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    COUNT(r.review_id) AS total_reviews
FROM olist_orders_dataset AS o
JOIN olist_order_reviews_dataset AS r
    ON o.order_id = r.order_id
GROUP BY o.order_status
ORDER BY average_review_score DESC;

-- Delivery performance analysis
SELECT
    ROUND(AVG(DATEDIFF(order_delivered_customer_date,order_purchase_timestamp)),2) AS avg_delivery_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL;
  
SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 'On Time or Early'
        ELSE 'Late'
    END AS delivery_performance,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_performance;

-- Payment method analysis
SELECT
    payment_type,
    COUNT(*) AS total_payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_payment_value DESC;