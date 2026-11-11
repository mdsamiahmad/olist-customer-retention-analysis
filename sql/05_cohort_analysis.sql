
-- =====================================================
-- OLIST E-COMMERCE DATA ANALYSIS
-- File: 05_cohort_analysis.sql
-- Database: olist_analysis
-- MySQL Version: 8.0+
-- =====================================================

USE olist_analysis;


-- 1. MONTHLY CUSTOMER ACQUISITION

SELECT
    DATE_FORMAT(
        MIN_ORDER_DATE,
        '%Y-%m'
    ) AS acquisition_month,
    COUNT(*) AS new_customers
FROM (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS MIN_ORDER_DATE
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) first_orders
GROUP BY acquisition_month
ORDER BY acquisition_month;


-- 2. CREATE CUSTOMER COHORTS

WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    DATE_FORMAT(first_purchase_date, '%Y-%m')
        AS cohort_month
FROM customer_first_purchase
ORDER BY first_purchase_date;


-- 3. MONTHLY CUSTOMER ACTIVITY

SELECT
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS order_month,

    COUNT(DISTINCT c.customer_unique_id)
        AS active_customers,

    COUNT(DISTINCT o.order_id)
        AS total_orders

FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id

WHERE o.order_status = 'delivered'

GROUP BY order_month
ORDER BY order_month;


-- 4. COHORT RETENTION ANALYSIS

WITH customer_first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

customer_activity AS (
    SELECT DISTINCT
        c.customer_unique_id,

        DATE_FORMAT(
            fp.first_purchase_date,
            '%Y-%m'
        ) AS cohort_month,

        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS activity_month,

        TIMESTAMPDIFF(
            MONTH,
            DATE_FORMAT(fp.first_purchase_date, '%Y-%m-01'),
            DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01')
        ) AS month_number

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN customer_first_purchase fp
        ON c.customer_unique_id = fp.customer_unique_id

    WHERE o.order_status = 'delivered'
),

cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id)
            AS total_cohort_customers
    FROM customer_activity
    WHERE month_number = 0
    GROUP BY cohort_month
),

cohort_retention AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_unique_id)
            AS retained_customers
    FROM customer_activity
    GROUP BY cohort_month, month_number
)

SELECT
    cr.cohort_month,
    cr.month_number,
    cs.total_cohort_customers,
    cr.retained_customers,

    ROUND(
        100.0 * cr.retained_customers /
        cs.total_cohort_customers,
        2
    ) AS retention_percentage

FROM cohort_retention cr

JOIN cohort_size cs
    ON cr.cohort_month = cs.cohort_month

ORDER BY
    cr.cohort_month,
    cr.month_number;


-- 5. COHORT RETENTION SUMMARY


-- COHORT RETENTION PERCENTAGE MATRIX

WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

activity AS (
    SELECT DISTINCT
        c.customer_unique_id,

        DATE_FORMAT(fp.first_date, '%Y-%m') AS cohort_month,

        TIMESTAMPDIFF(
            MONTH,
            DATE_FORMAT(fp.first_date, '%Y-%m-01'),
            DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01')
        ) AS month_number

    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN first_purchase fp
        ON c.customer_unique_id = fp.customer_unique_id

    WHERE o.order_status = 'delivered'
),

cohort_counts AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_unique_id) AS customers
    FROM activity
    GROUP BY cohort_month, month_number
),

cohort_size AS (
    SELECT
        cohort_month,
        MAX(
            CASE WHEN month_number = 0
            THEN customers END
        ) AS total_customers
    FROM cohort_counts
    GROUP BY cohort_month
)

SELECT
    cc.cohort_month,

    ROUND(
        MAX(CASE WHEN month_number = 0
            THEN 100.0 * customers / total_customers END), 2
    ) AS month_0,

    ROUND(
        MAX(CASE WHEN month_number = 1
            THEN 100.0 * customers / total_customers END), 2
    ) AS month_1,

    ROUND(
        MAX(CASE WHEN month_number = 2
            THEN 100.0 * customers / total_customers END), 2
    ) AS month_2,

    ROUND(
        MAX(CASE WHEN month_number = 3
            THEN 100.0 * customers / total_customers END), 2
    ) AS month_3,

    ROUND(
        MAX(CASE WHEN month_number = 4
            THEN 100.0 * customers / total_customers END), 2
    ) AS month_4,

    ROUND(
        MAX(CASE WHEN month_number = 5
            THEN 100.0 * customers / total_customers END), 2
    ) AS month_5,

    ROUND(
        MAX(CASE WHEN month_number = 6
            THEN 100.0 * customers / total_customers END), 2
    ) AS month_6

FROM cohort_counts cc
JOIN cohort_size cs
    ON cc.cohort_month = cs.cohort_month

GROUP BY cc.cohort_month
ORDER BY cc.cohort_month;