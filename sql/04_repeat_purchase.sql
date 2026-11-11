
-- =====================================================
-- OLIST E-COMMERCE DATA ANALYSIS
-- File: 04_repeat_purchase.sql
-- Database: olist_analysis
-- =====================================================

USE olist_analysis;


-- 1. TOTAL DELIVERED CUSTOMERS AND ORDERS

SELECT
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_delivered_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered';


-- 2. CUSTOMER PURCHASE FREQUENCY

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    total_orders,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY total_orders
ORDER BY total_orders;


-- 3. REPEAT PURCHASE RATE

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,

    SUM(total_orders >= 2) AS repeat_customers,

    SUM(total_orders = 1) AS one_time_customers,

    ROUND(
        100.0 * SUM(total_orders >= 2) / COUNT(*),
        2
    ) AS repeat_purchase_rate

FROM customer_orders;


-- 4. REPEAT CUSTOMER REVENUE

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

repeat_customers AS (
    SELECT customer_unique_id
    FROM customer_orders
    WHERE total_orders >= 2
),

customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    ROUND(SUM(cr.total_revenue), 2) AS repeat_customer_revenue
FROM customer_revenue cr
JOIN repeat_customers rc
    ON cr.customer_unique_id = rc.customer_unique_id;


-- 5. REPEAT CUSTOMER REVENUE CONTRIBUTION

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    ROUND(
        SUM(CASE
            WHEN co.total_orders >= 2
            THEN cr.total_revenue
            ELSE 0
        END), 2
    ) AS repeat_customer_revenue,

    ROUND(SUM(cr.total_revenue), 2) AS total_revenue,

    ROUND(
        100.0 * SUM(CASE
            WHEN co.total_orders >= 2
            THEN cr.total_revenue
            ELSE 0
        END) / SUM(cr.total_revenue),
        2
    ) AS repeat_revenue_percentage

FROM customer_orders co
JOIN customer_revenue cr
    ON co.customer_unique_id = cr.customer_unique_id;


-- 6. REVENUE BY CUSTOMER TYPE

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN co.total_orders >= 2 THEN 'Repeat Customers'
        ELSE 'One-Time Customers'
    END AS customer_type,

    COUNT(*) AS customer_count,

    ROUND(SUM(cr.total_revenue), 2) AS total_revenue,

    ROUND(AVG(cr.total_revenue), 2) AS average_customer_revenue

FROM customer_orders co
JOIN customer_revenue cr
    ON co.customer_unique_id = cr.customer_unique_id

GROUP BY customer_type
ORDER BY total_revenue DESC;


-- 7. TOP 10 REPEAT CUSTOMERS

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    co.customer_unique_id,
    co.total_orders,
    ROUND(cr.total_revenue, 2) AS total_revenue

FROM customer_orders co
JOIN customer_revenue cr
    ON co.customer_unique_id = cr.customer_unique_id

WHERE co.total_orders >= 2

ORDER BY total_revenue DESC
LIMIT 10;
