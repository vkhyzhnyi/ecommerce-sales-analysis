/*
=========================================================
E-Commerce Sales Analysis Project

File:
    01_data_cleaning.sql

Purpose:
    Data cleaning, standardization and quality checks.

Database:
    SQLite

Description:
    - Standardize inconsistent values
    - Convert date formats
    - Check missing data
    - Validate data quality
    - Detect duplicates

=========================================================
*/


/*
=========================================================
ONE-TIME DATABASE MODIFICATIONS

Run only once if required.
=========================================================
*/


-- Add column for standardized date format
-- Required for correct chronological sorting

-- ALTER TABLE time_dim ADD date_parsed TEXT;


-- Standardize unit naming conventions

-- UPDATE item_dim SET unit = TRIM(unit);

-- UPDATE item_dim SET unit = LOWER(unit);

-- UPDATE item_dim 
-- SET unit = "bags"
-- WHERE unit = "Bags" COLLATE BINARY;

-- UPDATE item_dim 
-- SET unit = "ct"
-- WHERE unit IN ("Ct", "ct.") COLLATE BINARY;

-- UPDATE item_dim 
-- SET unit = "oz"
-- WHERE unit = "oz." COLLATE BINARY;

-- UPDATE item_dim
-- SET unit = "bottles"
-- WHERE unit = "botlltes" COLLATE BINARY;


-- Rename column for better readability
-- Upazila = administrative unit in Bangladesh

-- ALTER TABLE store_dim
-- RENAME COLUMN upazila TO subdistrict;


-- Fix column name typo

-- ALTER TABLE customer_dim
-- RENAME COLUMN coustomer_key TO customer_key;

-- ALTER TABLE fact_table
-- RENAME COLUMN coustomer_key TO customer_key;



/*
=========================================================
DATE STANDARDIZATION

Convert original date format into YYYY-MM-DD HH:MM
for correct sorting and analysis.
=========================================================
*/


UPDATE time_dim
SET date_parsed =
    substr(Date, 7, 4) || '-' ||
    substr(Date, 4, 2) || '-' ||
    substr(Date, 1, 2) || ' ' ||
    substr(Date, 12)
WHERE Date IS NOT NULL;



/*
=========================================================
DATA QUALITY CHECKS
=========================================================
*/


-- Check converted dates

SELECT
    Date,
    date_parsed
FROM time_dim
ORDER BY date_parsed DESC
LIMIT 100;



-- Check missing product prices

SELECT *
FROM item_dim
WHERE unit_price = "";



-- Fix inconsistent country naming

UPDATE item_dim
SET man_country = "Poland"
WHERE man_country = "poland" COLLATE BINARY;



-- Evaluate customer name quality

SELECT
    customer_key,
    name,
    CASE
        WHEN name LIKE '%@%' THEN "invalid"
        WHEN name LIKE '%/%' THEN "invalid"
        WHEN length(name) < 3 THEN "too short"
        WHEN name IS NULL THEN "missing"
        ELSE "ok"
    END AS name_quality
FROM customer_dim;



/*
=========================================================
DUPLICATE CHECKS
=========================================================
*/


-- Total number of transactions

SELECT COUNT(*)
FROM fact_table;



-- Check unique transaction combinations

SELECT COUNT(DISTINCT
    customer_key ||
    item_key ||
    payment_key ||
    time_key
) AS unique_transactions
FROM fact_table;
