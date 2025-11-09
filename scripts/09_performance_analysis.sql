/*
===============================================================================
Title: Performance Analysis (Year-over-Year, Month-over-Month)
Author: Chinedu Anele
Role: Data Engineer
Date: 2025-11-09
===============================================================================
Purpose:
    - To measure performance changes of products, customers, or regions over time.
    - To compare current performance against historical data for trend identification.
    - To highlight growth or decline patterns for business decision-making.

Tables Referenced:
    - gold.fact_sales
    - gold.dim_products

SQL Functions Used:
    - LAG(): Accesses data from previous rows for comparison.
    - AVG() OVER(): Calculates average values across partitions.
    - CASE: Implements conditional logic for classifying performance trends.
===============================================================================
*/

/*
--------------------------------------------------------------------------------
Analysis Logic:
    1. Aggregate product sales by year.
    2. Compare each product’s yearly sales to:
        a. Its overall average performance (Above/Below Avg classification).
        b. Its previous year’s sales (Year-over-Year trend).
    3. Provide a detailed trend classification for strategic performance review.
--------------------------------------------------------------------------------
*/

WITH yearly_product_sales AS (
    -- Step 1: Aggregate yearly sales for each product
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)

-- Step 2: Compare yearly sales performance to historical benchmarks
SELECT
    order_year,
    product_name,
    current_sales,

    -- Compare against product’s average sales over time
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,

    -- Year-over-Year comparison (YoY)
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change

FROM yearly_product_sales
ORDER BY product_name, order_year;
