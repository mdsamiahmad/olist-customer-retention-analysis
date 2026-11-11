
-- ============================================================
-- OLIST E-COMMERCE DATA ANALYSIS
-- File: 07_rfm_segmentation.sql
-- Database: olist_analysis
-- MySQL Version: 8.0+
--
-- OBJECTIVE:
-- Customer segmentation using Recency, Frequency and Monetary
-- ============================================================

USE olist_analysis;


-- ============================================================
-- 1. CLEAN UP PREVIOUS TEMPORARY TABLES
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS temp_rfm_segments;
DROP TEMPORARY TABLE IF EXISTS temp_customer_rfm;


-- ============================================================
-- 2. CREATE CUSTOMER-LEVEL RFM METRICS
-- ============================================================

-- Reference date: 1 September 2018

CREATE TEMPORARY TABLE temp_customer_rfm AS

WITH payment_by_order AS (

    SELECT
        order_id,
        SUM(payment_value) AS order_payment
    FROM order_payments
    GROUP BY order_id

),

customer_metrics AS (

    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp)
            AS last_purchase_date,
        COUNT(DISTINCT o.order_id)
            AS frequency,
        COALESCE(SUM(p.order_payment), 0)
            AS monetary
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    LEFT JOIN payment_by_order p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    DATEDIFF(
        '2018-09-01',
        DATE(last_purchase_date)
    ) AS recency,
    frequency,
    ROUND(monetary, 2) AS monetary
FROM customer_metrics;


-- ============================================================
-- 3. VALIDATE RFM CUSTOMER POPULATION
-- ============================================================

SELECT
    COUNT(*) AS total_rfm_customers,
    COUNT(DISTINCT customer_unique_id)
        AS unique_rfm_customers,
    SUM(frequency) AS total_delivered_orders,
    SUM(monetary) AS total_customer_revenue
FROM temp_customer_rfm;


-- ============================================================
-- 4. CHECK CUSTOMERS WITHOUT PAYMENT RECORDS
-- ============================================================

SELECT
    COUNT(*) AS customers_without_payment
FROM temp_customer_rfm
WHERE monetary = 0;


-- ============================================================
-- 5. CALCULATE RFM SCORES
-- ============================================================

CREATE TEMPORARY TABLE temp_rfm_scores AS

SELECT
    customer_unique_id,
    recency,
    frequency,
    monetary,

    -- Recency: Lower days = Better score
    NTILE(5) OVER (
        ORDER BY recency DESC, customer_unique_id
    ) AS r_score,

    -- Frequency: Higher orders = Better score
    NTILE(5) OVER (
        ORDER BY frequency ASC, customer_unique_id
    ) AS f_score,

    -- Monetary: Higher spending = Better score
    NTILE(5) OVER (
        ORDER BY monetary ASC, customer_unique_id
    ) AS m_score

FROM temp_customer_rfm;


-- ============================================================
-- 6. CREATE NINE-SEGMENT CUSTOMER CLASSIFICATION
-- ============================================================

CREATE TEMPORARY TABLE temp_rfm_segments AS

SELECT
    customer_unique_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,

    CONCAT(r_score, f_score, m_score) AS rfm_score,

    CASE
        WHEN r_score >= 4
             AND f_score >= 4
             AND m_score >= 4
            THEN 'Champions'
        WHEN r_score <= 2
             AND f_score >= 4
            THEN 'Cannot Lose Them'
        WHEN r_score <= 2
             AND f_score = 3
            THEN 'At Risk'
        WHEN r_score >= 3
             AND f_score >= 3
            THEN 'Loyal Customers'
        WHEN r_score = 5
             AND f_score = 1
            THEN 'New Customers'
        WHEN r_score >= 4
             AND f_score <= 2
            THEN 'Potential Loyalists'
        WHEN r_score = 3
             AND f_score <= 2
            THEN 'Need Attention'
        WHEN r_score <= 2
             AND f_score <= 2
            THEN 'Hibernating'
        ELSE 'Others'
    END AS customer_segment
FROM temp_rfm_scores;

-- ============================================================
-- 7. CUSTOMER DISTRIBUTION BY SEGMENT
-- ============================================================

WITH segment_counts AS (

    SELECT
        customer_segment,
        COUNT(*) AS total_customers
    FROM temp_rfm_segments
    GROUP BY customer_segment
)
SELECT
    customer_segment,
    total_customers,
    ROUND(
        100.0 * total_customers /
        SUM(total_customers) OVER (),
        2
    ) AS customer_percentage
FROM segment_counts
ORDER BY total_customers DESC;

-- ============================================================
-- 8. REVENUE CONTRIBUTION BY SEGMENT
-- ============================================================

WITH segment_revenue AS (

    SELECT
        customer_segment,
        COUNT(*) AS total_customers,
        SUM(monetary) AS total_revenue,
        AVG(monetary) AS average_customer_revenue
    FROM temp_rfm_segments
    GROUP BY customer_segment
)
SELECT
    customer_segment,
    total_customers,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(
        100.0 * total_revenue /
        SUM(total_revenue) OVER (),
        2
    ) AS revenue_percentage,
    ROUND(
        average_customer_revenue, 2
    ) AS average_customer_revenue
FROM segment_revenue
ORDER BY total_revenue DESC;

-- ============================================================
-- 9. AT-RISK CUSTOMER ANALYSIS
-- ============================================================

SELECT
    COUNT(*) AS at_risk_customers,
    ROUND(SUM(monetary), 2) AS at_risk_revenue,
    ROUND(AVG(recency), 2) AS average_recency_days,
    ROUND(AVG(frequency), 2) AS average_frequency
FROM temp_rfm_segments
WHERE customer_segment = 'At Risk';
-- ============================================================
-- 10. HIBERNATING CUSTOMER ANALYSIS
-- ============================================================

SELECT
    COUNT(*) AS hibernating_customers,
    ROUND(SUM(monetary), 2) AS hibernating_revenue,
    ROUND(AVG(recency), 2) AS average_recency_days,
    ROUND(AVG(frequency), 2) AS average_frequency
FROM temp_rfm_segments
WHERE customer_segment = 'Hibernating';


-- ============================================================
-- 11. CHAMPIONS CUSTOMER ANALYSIS
-- ============================================================

SELECT
    COUNT(*) AS champions_customers,
    ROUND(SUM(monetary), 2) AS champions_revenue,
    ROUND(AVG(monetary), 2) AS average_customer_spending
FROM temp_rfm_segments
WHERE customer_segment = 'Champions';


-- ============================================================
-- 12. TOP 20 CUSTOMERS BY MONETARY VALUE
-- ============================================================

SELECT
    customer_unique_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    rfm_score,
    customer_segment
FROM temp_rfm_segments
ORDER BY monetary DESC
LIMIT 20;


-- ============================================================
-- 13. FINAL RFM SEGMENT SUMMARY
-- ============================================================

SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(recency), 2) AS average_recency,
    ROUND(AVG(frequency), 2) AS average_frequency,
    ROUND(AVG(monetary), 2) AS average_monetary,
    ROUND(SUM(monetary), 2) AS total_revenue
FROM temp_rfm_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;


-- ============================================================
-- 14. RFM SCORE DISTRIBUTION
-- ============================================================

SELECT
    r_score,
    f_score,
    m_score,
    COUNT(*) AS total_customers
FROM temp_rfm_segments
GROUP BY
    r_score,
    f_score,
    m_score
ORDER BY
    r_score,
    f_score,
    m_score;


-- ============================================================
-- 15. FINAL CUSTOMER COUNT VALIDATION
-- ============================================================

SELECT
    (SELECT COUNT(DISTINCT c.customer_unique_id)
     FROM customers c
     JOIN orders o
       ON c.customer_id = o.customer_id
     WHERE o.order_status = 'delivered')
        AS actual_delivered_customers,

    (SELECT COUNT(*)
     FROM temp_rfm_segments)
        AS rfm_customers;


-- ============================================================
-- END OF RFM SEGMENTATION
-- ============================================================
