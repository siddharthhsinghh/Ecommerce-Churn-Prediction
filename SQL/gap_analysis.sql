USE churn;

WITH orders_clean AS (
    SELECT c.customer_unique_id,
           o.order_purchase_timestamp AS purchase_ts
    FROM olist_orders_dataset AS o
    JOIN olist_customers_dataset AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
gaps AS (
    SELECT customer_unique_id,
           DATEDIFF(
               purchase_ts,
               LAG(purchase_ts) OVER (PARTITION BY customer_unique_id ORDER BY purchase_ts)
           ) AS gap_days
    FROM orders_clean
)
SELECT
    CASE
        WHEN gap_days <= 30  THEN '1) 0-30'
        WHEN gap_days <= 60  THEN '2) 31-60'
        WHEN gap_days <= 90  THEN '3) 61-90'
        WHEN gap_days <= 180 THEN '4) 91-180'
        WHEN gap_days <= 365 THEN '5) 181-365'
        ELSE '6) 365+'
    END AS bucket,
    COUNT(*) AS gaps,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM gaps
WHERE gap_days IS NOT NULL
GROUP BY bucket
ORDER BY bucket;

USE churn;

SELECT
    COUNT(*)                                        AS total_customers,
    SUM(order_count > 1)                            AS repeat_customers,
    ROUND(100 * SUM(order_count > 1) / COUNT(*), 2) AS repeat_pct
FROM (
    SELECT c.customer_unique_id, COUNT(*) AS order_count
    FROM olist_orders_dataset AS o
    JOIN olist_customers_dataset AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id
) AS t;

USE churn;

WITH orders_clean AS (
    SELECT c.customer_unique_id, o.order_purchase_timestamp AS purchase_ts
    FROM olist_orders_dataset AS o
    JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
gaps AS (
    SELECT customer_unique_id,
           DATEDIFF(purchase_ts,
                    LAG(purchase_ts) OVER (PARTITION BY customer_unique_id ORDER BY purchase_ts)) AS gap_days
    FROM orders_clean
)
SELECT COUNT(*)                                   AS total_gaps,
       SUM(gap_days = 0)                          AS same_day,
       SUM(gap_days BETWEEN 1 AND 7)              AS days_1_to_7,
       ROUND(100 * SUM(gap_days = 0) / COUNT(*), 2) AS same_day_pct
FROM gaps
WHERE gap_days IS NOT NULL;

USE churn;
SET @snapshot = '2018-03-01';
SET @n = 90;

SELECT @snapshot AS snapshot_date, @n AS n_days,
       COUNT(*)                                   AS eligible_customers,
       SUM(returned)                              AS returners,
       ROUND(100 * SUM(returned) / COUNT(*), 2)   AS return_pct
FROM (
    SELECT c.customer_unique_id,
           MAX(o.order_purchase_timestamp >= @snapshot) AS returned
    FROM olist_orders_dataset AS o
    JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp < DATE_ADD(@snapshot, INTERVAL @n DAY)
    GROUP BY c.customer_unique_id
    HAVING MIN(o.order_purchase_timestamp) < @snapshot
) AS t;

USE churn;
SET @snapshot = '2018-06-01';
SET @n = 90;

SELECT @snapshot AS snapshot_date, @n AS n_days,
       COUNT(*)                                   AS eligible_customers,
       SUM(returned)                              AS returners,
       ROUND(100 * SUM(returned) / COUNT(*), 2)   AS return_pct
FROM (
    SELECT c.customer_unique_id,
           MAX(o.order_purchase_timestamp >= @snapshot) AS returned
    FROM olist_orders_dataset AS o
    JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp < DATE_ADD(@snapshot, INTERVAL @n DAY)
    GROUP BY c.customer_unique_id
    HAVING MIN(o.order_purchase_timestamp) < @snapshot
) AS t;

USE churn;
SET @snapshot = '2017-09-01';
SET @n = 180;

SELECT @snapshot AS snapshot_date, @n AS n_days,
       COUNT(*)                                   AS eligible_customers,
       SUM(returned)                              AS returners,
       ROUND(100 * SUM(returned) / COUNT(*), 2)   AS return_pct
FROM (
    SELECT c.customer_unique_id,
           MAX(o.order_purchase_timestamp >= @snapshot) AS returned
    FROM olist_orders_dataset AS o
    JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp < DATE_ADD(@snapshot, INTERVAL @n DAY)
    GROUP BY c.customer_unique_id
    HAVING MIN(o.order_purchase_timestamp) < @snapshot
) AS t;