
-- =====================================================
-- OLIST E-COMMERCE DATA ANALYSIS
-- File: 06_delivery_review_analysis.sql
-- Database: olist_analysis
-- MySQL Version: 8.0+
-- =====================================================

USE olist_analysis;


-- 1. TOTAL DELIVERED ORDERS

SELECT
    COUNT(*) AS total_delivered_orders
FROM orders
WHERE order_status = 'delivered';


-- 2. LATE VS ON-TIME DELIVERY

SELECT
    COUNT(*) AS total_orders,

    SUM(
        order_delivered_customer_date >
        order_estimated_delivery_date
    ) AS late_orders,

    SUM(
        order_delivered_customer_date <=
        order_estimated_delivery_date
    ) AS on_time_orders,

    ROUND(
        100.0 * SUM(
            order_delivered_customer_date >
            order_estimated_delivery_date
        ) / COUNT(*),
        2
    ) AS late_delivery_percentage

FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


-- 3. AVERAGE DELIVERY TIME IN DAYS

SELECT
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                HOUR,
                order_purchase_timestamp,
                order_delivered_customer_date
            ) / 24.0
        ),
        2
    ) AS average_delivery_days

FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


-- 4. AVERAGE DELIVERY DELAY

SELECT
    ROUND(
        AVG(
            GREATEST(
                TIMESTAMPDIFF(
                    HOUR,
                    order_estimated_delivery_date,
                    order_delivered_customer_date
                ) / 24.0,
                0
            )
        ),
        2
    ) AS average_delay_days

FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date >
      order_estimated_delivery_date;


-- 5. DELIVERY PERFORMANCE DISTRIBUTION

SELECT
    CASE
        WHEN order_delivered_customer_date >
             order_estimated_delivery_date
            THEN 'Late Delivery'
        ELSE 'On-Time Delivery'
    END AS delivery_status,

    COUNT(*) AS total_orders,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL

GROUP BY delivery_status;


-- 6. AVERAGE REVIEW SCORE BY DELIVERY STATUS

SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
            THEN 'Late Delivery'
        ELSE 'On-Time Delivery'
    END AS delivery_status,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(r.review_id) AS review_records,

    ROUND(AVG(r.review_score), 2) AS average_review_score

FROM orders o

JOIN order_reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY delivery_status;


-- 7. REVIEW SCORE DISTRIBUTION

SELECT
    r.review_score,

    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
            THEN 'Late Delivery'
        ELSE 'On-Time Delivery'
    END AS delivery_status,

    COUNT(*) AS total_reviews

FROM orders o

JOIN order_reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    r.review_score,
    delivery_status

ORDER BY
    r.review_score,
    delivery_status;


-- 8. DELIVERY PERFORMANCE BY STATE

SELECT
    c.customer_state,

    COUNT(*) AS total_orders,

    SUM(
        o.order_delivered_customer_date >
        o.order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        100.0 * SUM(
            o.order_delivered_customer_date >
            o.order_estimated_delivery_date
        ) / COUNT(*),
        2
    ) AS late_delivery_percentage

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY c.customer_state

ORDER BY late_delivery_percentage DESC;


-- 9. MONTHLY DELIVERY PERFORMANCE

SELECT
    DATE_FORMAT(
        order_purchase_timestamp,
        '%Y-%m'
    ) AS order_month,

    COUNT(*) AS total_orders,

    SUM(
        order_delivered_customer_date >
        order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        100.0 * SUM(
            order_delivered_customer_date >
            order_estimated_delivery_date
        ) / COUNT(*),
        2
    ) AS late_delivery_percentage

FROM orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL

GROUP BY order_month

ORDER BY order_month;


-- 10. DELIVERY TIME VS CUSTOMER REVIEW

SELECT
    CASE
        WHEN DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        ) <= 7 THEN '0-7 Days'

        WHEN DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        ) <= 14 THEN '8-14 Days'

        WHEN DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        ) <= 21 THEN '15-21 Days'

        ELSE 'Above 21 Days'
    END AS delivery_duration,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(AVG(r.review_score), 2) AS average_review_score

FROM orders o

JOIN order_reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY delivery_duration

ORDER BY MIN(
    DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    )
);
