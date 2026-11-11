
-- =====================================================
-- OLIST E-COMMERCE DATA ANALYSIS
-- File: 02_data_validation.sql
-- Database: olist_analysis
-- MySQL Version: 8.0+
-- =====================================================

USE olist_analysis;


-- 1. RECORD COUNT OF ALL 9 TABLES

SELECT 'customers' AS table_name, COUNT(*) AS total_records FROM customers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation;


-- 2. CUSTOMER DATA VALIDATION

SELECT
    COUNT(*) AS total_rows,
    COUNT(customer_id) AS customer_id_present,
    COUNT(customer_unique_id) AS unique_id_present,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(customer_unique_id IS NULL) AS null_unique_id
FROM customers;


-- 3. ORDER DATA VALIDATION

SELECT
    COUNT(*) AS total_orders,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(order_status IS NULL) AS null_order_status,
    SUM(order_purchase_timestamp IS NULL) AS null_purchase_date,
    SUM(order_delivered_customer_date IS NULL) AS null_delivery_date
FROM orders;


-- 4. DUPLICATE CUSTOMER IDs

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- 5. DUPLICATE ORDER IDs

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- 6. INVALID REVIEW SCORES

SELECT
    review_score,
    COUNT(*) AS total_records
FROM order_reviews
WHERE review_score NOT BETWEEN 1 AND 5
   OR review_score IS NULL
GROUP BY review_score;


-- 7. INVALID ORDER DATES

SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date
      < order_purchase_timestamp;


-- 8. ORDERS WITHOUT CUSTOMER MATCH

SELECT COUNT(*) AS unmatched_customer_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- 9. ORDER ITEMS WITHOUT ORDER MATCH

SELECT COUNT(*) AS unmatched_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 10. ORDER ITEMS WITHOUT PRODUCT MATCH

SELECT COUNT(*) AS unmatched_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- 11. ORDER ITEMS WITHOUT SELLER MATCH

SELECT COUNT(*) AS unmatched_sellers
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- 12. NEGATIVE OR ZERO PAYMENT VALUES

SELECT *
FROM order_payments
WHERE payment_value <= 0;


-- 13. NEGATIVE PRODUCT PRICES OR FREIGHT

SELECT *
FROM order_items
WHERE price < 0
   OR freight_value < 0;


-- 14. ORDER STATUS DISTRIBUTION

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders), 2
    ) AS percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 15. MISSING DELIVERY DATE BY ORDER STATUS

SELECT
    order_status,
    COUNT(*) AS total_orders,
    SUM(order_delivered_customer_date IS NULL)
        AS missing_delivery_dates
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;
