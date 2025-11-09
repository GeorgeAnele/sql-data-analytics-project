/*
===============================================================================
SCRIPT:        part_to_whole_analysis.sql
AUTHOR:        Chinedu Anele
CREATED ON:    2025-11-09
===============================================================================
DESCRIPTION:
    This SQL script performs a Part-to-Whole Analysis to determine how each 
    product category contributes to the overall sales performance. It aggregates 
    sales at the category level, computes the percentage contribution of each 
    category to total sales, and ranks them for performance insights.

    This analysis supports business questions such as:
        - Which categories generate the highest share of total revenue?
        - What proportion of sales each category contributes to the company total?
        - How to prioritize marketing and inventory based on revenue distribution.

===============================================================================
===============================================================================
BUSINESS VALUE:
    Enables performance benchmarking across product categories and 
    informs strategic decisions such as category prioritization, 
    pricing, and promotional focus areas.
===============================================================================
*/

-- ============================================================
-- STEP 1: Aggregate total sales by product category
-- ============================================================
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category
)

-- ============================================================
-- STEP 2: Calculate total company sales and category contribution %
-- ============================================================
SELECT
    category,                                 -- Product category name
    total_sales,                              -- Total revenue from that category
    SUM(total_sales) OVER () AS overall_sales, -- Total company-wide sales
    ROUND(
        (CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100,
        2
    ) AS percentage_of_total                  -- Category’s % contribution to total
FROM category_sales
ORDER BY total_sales DESC;                    -- Rank categories by sales volume
