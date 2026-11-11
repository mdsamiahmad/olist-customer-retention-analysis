
-- =====================================================
-- OLIST E-COMMERCE DATA ANALYSIS
-- File: 01_schema.sql
-- Database: olist_analysis
-- MySQL Version: 8.0+
-- =====================================================

USE olist_analysis;

-- 1. Verify database
SELECT DATABASE() AS current_database;

-- 2. List all tables
SHOW TABLES;

-- 3. Inspect all 9 table structures

DESCRIBE customers;
DESCRIBE geolocation;
DESCRIBE order_items;
DESCRIBE order_payments;
DESCRIBE order_reviews;
DESCRIBE orders;
DESCRIBE products;
DESCRIBE sellers;
DESCRIBE category_translation;

-- 4. Get detailed column information
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_KEY,
    EXTRA
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'olist_analysis'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- 5. Identify primary and foreign keys
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'olist_analysis'
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- 6. Check table storage information
SELECT
    TABLE_NAME,
    TABLE_ROWS,
    ENGINE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'olist_analysis'
ORDER BY TABLE_NAME;
