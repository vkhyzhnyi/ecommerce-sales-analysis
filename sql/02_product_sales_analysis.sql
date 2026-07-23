/*
=========================================================
E-Commerce Sales Analysis Project

File:
    02_product_sales_analysis.sql

Purpose:
    Product performance and sales analysis.

Database:
    SQLite

Description:
    - Identify top revenue-generating products
    - Analyze sales trends over time
    - Compare average transaction values
    - Evaluate product sales consistency
    - Measure product contribution to total revenue

=========================================================
*/


/*
=========================================================
TOP PRODUCTS BY REVENUE

Business Question:
Which products generate the highest revenue?

Metrics:
- Units sold
- Total revenue

=========================================================
*/


SELECT
    i.item_key,
    i.item_name,
    SUM(f.quantity) AS units_sold,
    SUM(f.total_price) AS revenue
FROM fact_table f
JOIN item_dim i
    ON f.item_key = i.item_key
GROUP BY
    i.item_key,
    i.item_name
ORDER BY revenue DESC
LIMIT 20;



/*
=========================================================
MONTHLY SALES TREND

Business Question:
How does revenue change over time?

=========================================================
*/


SELECT
    year,
    month,
    SUM(total_price) AS revenue
FROM fact_table f
JOIN time_dim t
    ON f.time_key = t.time_key
GROUP BY
    year,
    month
ORDER BY
    year,
    month;



/*
=========================================================
DAILY SALES TREND

Business Question:
Which days generate the highest revenue?

=========================================================
*/


SELECT
    year,
    month,
    day,
    SUM(total_price) AS revenue
FROM fact_table f
JOIN time_dim t
    ON f.time_key = t.time_key
GROUP BY
    year,
    month,
    day
ORDER BY
    year DESC,
    month,
    day;



/*
=========================================================
AVERAGE REVENUE PER PRODUCT

Business Question:
Which products are associated with higher-value transactions?

Metric:
Average transaction value

=========================================================
*/


SELECT
    i.item_key,
    i.item_name,
    ROUND(AVG(f.total_price), 2) AS avg_transaction_value
FROM fact_table f
JOIN item_dim i
    ON f.item_key = i.item_key
GROUP BY
    i.item_key,
    i.item_name
ORDER BY avg_transaction_value DESC;



/*
=========================================================
PRODUCT SALES CONSISTENCY

Business Question:
Which products maintain stable sales performance
throughout the year?

Metric:
Monthly units sold

=========================================================
*/


SELECT
    i.item_name,
    t.month,
    SUM(f.quantity) AS units_sold
FROM fact_table f
JOIN item_dim i
    ON f.item_key = i.item_key
JOIN time_dim t
    ON f.time_key = t.time_key
GROUP BY
    i.item_key,
    t.month
ORDER BY
    i.item_name,
    t.month;



/*
=========================================================
PRODUCT REVENUE CONTRIBUTION

Business Question:
Which products contribute the most to overall revenue?

Metric:
Revenue share (%)

=========================================================
*/


SELECT
    i.item_name,
    SUM(f.total_price) AS revenue,
    ROUND(
        SUM(f.total_price) * 100.0 /
        (SELECT SUM(total_price) FROM fact_table),
        2
    ) AS revenue_share_percentage
FROM fact_table f
JOIN item_dim i
    ON f.item_key = i.item_key
GROUP BY
    i.item_key,
    i.item_name
ORDER BY revenue_share_percentage DESC;
