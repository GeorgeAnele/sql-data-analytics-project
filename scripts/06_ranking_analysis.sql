/*
===============================================================================
Title: Ranking Analysis Script
Author: Chinedu Anele
Role: Data Engineer
Date: 2025-11-09
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance metrics such as revenue or order volume.
    - To identify top performers (best sellers, high-value customers) and underperformers (lowest sales).

Tables Referenced:
    - gold.fact_sales
    - gold.dim_products
    - gold.dim_customers

SQL Functions Used:
    - Window Functions: RANK(), DENSE_RANK(), ROW_NUMBER()
    - Clauses: GROUP BY, ORDER BY, TOP
===============================================================================
*/

-- Retrieve the top 5 products generating the highest revenue
-- (Simple ranking using TOP and ORDER BY)
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Retrieve the top 5 products using window functions for flexible ranking
-- (Allows extending the logic beyond static limits like TOP)
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;

-- Retrieve the 5 worst-performing products based on total revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue;

-- Retrieve the top 10 customers generating the highest revenue
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- Retrieve the 3 customers with the fewest orders placed
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders;
