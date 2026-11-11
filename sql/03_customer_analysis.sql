
-- =====================================================
-- OLIST E-COMMERCE DATA ANALYSIS
-- File: 03_customer_analysis.sql
-- Database: olist_analysis
-- MySQL Version: 8.0+
-- =====================================================

USE olist_analysis;


-- 1. TOTAL CUSTOMERS

SELECT
    COUNT(DISTINCT c.customer_id) AS total_customer_records,
    COUNT(DISTINCT c.customer_unique_id) AS total_unique_customers,

    COUNT(DISTINCT CASE
        WHEN o.order_status = 'delivered'
        THEN c.customer_unique_id
    END) AS delivered_customers,

    COUNT(DISTINCT CASE
        WHEN o.order_status = 'delivered'
        THEN o.order_id
    END) AS delivered_orders

FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;


-- 2. CUSTOMER DISTRIBUTION BY STATE

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;


-- 3. TOP 10 CUSTOMER CITIES

SELECT
    customer_city,
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers
GROUP BY customer_city, customer_state
ORDER BY total_customers DESC
LIMIT 10;


-- 4. TOTAL REVENUE

SELECT
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM order_payments;


-- 5. AVERAGE ORDER VALUE

WITH order_revenue AS (
    SELECT
        order_id,
        SUM(payment_value) AS order_value
    FROM order_payments
    GROUP BY order_id
)
SELECT
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_revenue;


-- 6. CUSTOMER PURCHASE FREQUENCY

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


-- 7. RFM ANALYSIS

-- Recency: Days since last purchase
-- Frequency: Number of delivered orders
-- Monetary: Total payment value

WITH customer_rfm AS (
    SELECT
        c.customer_unique_id,

        DATEDIFF(
            DATE '2018-09-01',
            MAX(o.order_purchase_timestamp)
        ) AS recency,

        COUNT(DISTINCT o.order_id) AS frequency,

        SUM(p.payment_value) AS monetary

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_payments p
        ON o.order_id = p.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
),

rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (
            ORDER BY recency DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS m_score

    FROM customer_rfm
)

SELECT
    customer_unique_id,
    recency,
    frequency,
    ROUND(monetary, 2) AS monetary,
    r_score,
    f_score,
    m_score,

    CASE
        WHEN r_score >= 4 AND f_score >= 4
             AND m_score >= 4
            THEN 'Champions'

        WHEN r_score >= 3 AND f_score >= 3
            THEN 'Loyal Customers'

        WHEN r_score >= 4 AND f_score <= 2
            THEN 'Potential Loyalists'

        WHEN r_score <= 2 AND f_score >= 3
            THEN 'At Risk'

        WHEN r_score <= 2 AND f_score <= 2
            THEN 'Hibernating'

        WHEN r_score >= 4 AND f_score <= 2
            THEN 'New Customers'

        ELSE 'Others'
    END AS customer_segment

FROM rfm_scores;


-- 8. REVENUE BY CUSTOMER STATE

SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- 9. TOP 10 CUSTOMERS BY REVENUE

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_spending
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY total_spending DESC
LIMIT 10;
