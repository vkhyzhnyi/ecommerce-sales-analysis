/*
=========================================================
E-Commerce Sales Analysis Project

File:
    03_rfm_customer_analysis.sql

Purpose:
    Customer analysis using RFM methodology.

RFM:
    Recency  - How recently a customer purchased
    Frequency - How often a customer purchases
    Monetary - How much revenue a customer generates

Database:
    SQLite
=========================================================
*/


-- =========================================
-- 1. MONETARY VALUE (M)
-- Top customers by total revenue
-- =========================================

SELECT
    customer_key,
    SUM(total_price) AS total_revenue
FROM fact_table
GROUP BY customer_key
ORDER BY total_revenue DESC
LIMIT 50;



-- =========================================
-- 2. FREQUENCY (F)
-- Customers with the highest number of orders
-- =========================================

SELECT
    customer_key,
    COUNT(*) AS order_count
FROM fact_table
GROUP BY customer_key
ORDER BY order_count DESC
LIMIT 10;



-- Customers with high purchase frequency (>100 orders)

SELECT
    customer_key,
    COUNT(*) AS order_count
FROM fact_table
GROUP BY customer_key
HAVING COUNT(*) > 100;



-- =========================================
-- 3. RECENCY (R)
-- Days since customer's last purchase
-- Lower value = more active customer
-- =========================================

SELECT
    customer_key,
    MAX(t.date_parsed) AS last_purchase_date,
    ROUND(
        JULIANDAY((SELECT MAX(date_parsed) FROM time_dim))
        - JULIANDAY(MAX(t.date_parsed))
    ) AS recency_days
FROM fact_table f
JOIN time_dim t
    ON f.time_key = t.time_key
GROUP BY customer_key
ORDER BY recency_days ASC;



-- =========================================
-- Recency customer grouping
-- =========================================

SELECT
    customer_key,
    CASE
        WHEN JULIANDAY((SELECT MAX(date_parsed) FROM time_dim))
             - JULIANDAY(MAX(t.date_parsed)) <= 30
            THEN '0-30 days'

        WHEN JULIANDAY((SELECT MAX(date_parsed) FROM time_dim))
             - JULIANDAY(MAX(t.date_parsed)) <= 90
            THEN '31-90 days'

        WHEN JULIANDAY((SELECT MAX(date_parsed) FROM time_dim))
             - JULIANDAY(MAX(t.date_parsed)) <= 180
            THEN '91-180 days'

        ELSE '180+ days'
    END AS recency_group
FROM fact_table f
JOIN time_dim t
    ON f.time_key = t.time_key
GROUP BY customer_key;



-- =========================================
-- 4. HIGH-VALUE CUSTOMERS (F + M)
-- Customers with high activity and high spending
-- =========================================

SELECT
    customer_key,
    order_count,
    revenue
FROM (
    SELECT
        customer_key,
        COUNT(*) AS order_count,
        SUM(total_price) AS revenue
    FROM fact_table
    GROUP BY customer_key
)
ORDER BY revenue DESC;



-- =========================================
-- 5. COMPLETE RFM TABLE
-- Customer-level RFM metrics
-- =========================================

SELECT
    f.customer_key,

    COUNT(*) AS frequency,

    SUM(f.total_price) AS monetary,

    ROUND(
        JULIANDAY((SELECT MAX(date_parsed) FROM time_dim))
        - JULIANDAY(MAX(t.date_parsed))
    ) AS recency

FROM fact_table f
JOIN time_dim t
    ON f.time_key = t.time_key
GROUP BY f.customer_key;