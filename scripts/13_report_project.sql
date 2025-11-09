/*
===============================================================================
SCRIPT:         product_report_view.sql
AUTHOR:         Chinedu Anele
CREATED ON:     2025-11-09
===============================================================================
DESCRIPTION:
    This SQL script creates the `gold.report_products` view, which consolidates 
    and aggregates product-related metrics for analysis and reporting purposes. 
    It provides insights into product performance, customer engagement, revenue 
    contribution, and lifecycle metrics.

===============================================================================
OBJECTIVE:
    To produce a comprehensive product report that includes:
        1. Product identification and metadata (name, category, subcategory, cost)
        2. Segmentation of products based on revenue performance (High, Mid, Low)
        3. Key metrics aggregation:
            - Total orders
            - Total sales
            - Total quantity sold
            - Unique customers
            - Product lifespan
        4. KPI computation:
            - Recency (months since last sale)
            - Average Order Revenue (AOR)
            - Average Monthly Revenue (AMR)

===============================================================================
DATA SOURCES:
    - gold.fact_sales       → Fact table with transactional data
    - gold.dim_products     → Product dimension table

===============================================================================
SQL FEATURES USED:
    - CTEs (Common Table Expressions) for modular query design
    - Aggregation Functions: SUM(), COUNT(), AVG()
    - Window Functions: None (but easy to extend)
    - Date Functions: DATEDIFF() for lifespan and recency
    - Conditional Logic: CASE statements for segmentation
    - Data Type Casting: CAST() and NULLIF() for safe division

===============================================================================
BUSINESS VALUE:
    Provides actionable insights to:
        - Identify top-performing products for marketing focus
        - Track product lifecycle and sales recency
        - Support pricing and inventory management decisions
        - Understand customer engagement with products

===============================================================================
*/

-- =============================================================================
-- STEP 0: Drop the existing view if it exists (ensures idempotency)
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

-- =============================================================================
-- STEP 1: Create the consolidated Product Report View
-- =============================================================================
CREATE VIEW gold.report_products AS

-- ============================================================================
-- CTE #1: Base Query - Retrieves transactional and product details
-- ============================================================================
WITH base_query AS (
    SELECT
        f.order_number,      -- Unique order ID
        f.order_date,        -- Date of sale
        f.customer_key,      -- Customer reference
        f.sales_amount,      -- Revenue generated
        f.quantity,          -- Units sold
        p.product_key,       -- Product surrogate key
        p.product_name,      -- Product name
        p.category,          -- Product category
        p.subcategory,       -- Product subcategory
        p.cost               -- Product cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL  -- Only valid sales considered
),

-- ============================================================================
-- CTE #2: Product Aggregations - Summarize metrics at product level
-- ============================================================================
product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan, -- Duration of sales activity
        MAX(order_date) AS last_sale_date,                             -- Most recent sale
        COUNT(DISTINCT order_number) AS total_orders,                  -- Unique orders
        COUNT(DISTINCT customer_key) AS total_customers,              -- Unique customers
        SUM(sales_amount) AS total_sales,                              -- Total revenue
        SUM(quantity) AS total_quantity,                               -- Total units sold
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price -- Avg unit price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

-- ============================================================================
-- STEP 3: Final Output - Compute KPIs and categorize products
-- ============================================================================
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months, -- Months since last sale
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,   -- Revenue-based product segmentation
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,
    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
FROM product_aggregations;
