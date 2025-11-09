/*
===============================================================================
Title: Data Segmentation Analysis
Author: Chinedu Anele
Role: Data Engineer
Date: 2025-11-09
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - Useful for customer segmentation, product categorization, and regional analysis.
    - Enables marketing, pricing, and performance differentiation strategies.

Tables Referenced:
    - gold.dim_products
    - gold.dim_customers
    - gold.fact_sales

SQL Functions Used:
    - CASE: Defines conditional segmentation logic.
    - GROUP BY: Aggregates data into defined segments.
    - DATEDIFF(): Measures customer relationship lifespan.
===============================================================================
*/

/*
--------------------------------------------------------------------------------
Product Segmentation
--------------------------------------------------------------------------------
Goal:
    - Classify products based on their cost ranges.
    - Identify product distribution across defined pricing tiers.
--------------------------------------------------------------------------------
*/
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


/*
--------------------------------------------------------------------------------
Customer Segmentation
--------------------------------------------------------------------------------
Goal:
    - Classify customers based on their spending behavior and duration of activity.
    - Segments:
        * VIP: ≥ 12 months and spending > €5,000
        * Regular: ≥ 12 months and spending ≤ €5,000
        * New: < 12 months lifespan
--------------------------------------------------------------------------------
*/
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
