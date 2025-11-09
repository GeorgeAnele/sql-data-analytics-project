/*
===============================================================================
SCRIPT:         customer_report_view.sql
AUTHOR:         Chinedu Anele
CREATED ON:     2025-11-09
===============================================================================
DESCRIPTION:
    This SQL script creates the `gold.report_customers` view, which consolidates 
    and aggregates customer-related metrics across transactional and demographic 
    dimensions. It supports analytical reporting, segmentation, and KPI 
    computation for downstream dashboards and customer analytics.

===============================================================================
OBJECTIVE:
    To produce a unified customer profile that captures:
        1. Demographic details (name, age, age group)
        2. Behavioral insights (spending, recency, lifespan)
        3. Segmentation logic (VIP, Regular, New)
        4. Core metrics (orders, sales, quantity, products)

===============================================================================
DATA SOURCES:
    - gold.fact_sales       → Fact table containing transactional data
    - gold.dim_customers    → Dimension table containing customer attributes

===============================================================================
KEY METRICS:
    - Total Orders
    - Total Sales
    - Total Quantity Purchased
    - Total Unique Products Bought
    - Lifespan (Months between first and last purchase)
    - Recency (Months since last purchase)
    - Average Order Value (AOV)
    - Average Monthly Spend (AMS)

===============================================================================
SQL FEATURES USED:
    - CTEs (Common Table Expressions)
    - Conditional Logic (CASE)
    - Aggregation Functions (SUM, COUNT, MAX, MIN)
    - Date Functions (DATEDIFF)
    - String Concatenation (CONCAT)
===============================================================================
BUSINESS VALUE:
    This customer report enables marketing, retention, and sales teams to:
        - Identify high-value (VIP) customers.
        - Track spending trends and lifecycle performance.
        - Tailor engagement strategies based on customer segments.
===============================================================================
*/

-- =============================================================================
-- STEP 0: Drop the existing view if it exists (ensures idempotency)
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO


-- =============================================================================
-- STEP 1: Create the consolidated Customer Report View
-- =============================================================================
CREATE VIEW gold.report_customers AS

-- ============================================================================
-- CTE #1: Base Query - Retrieves core transaction and demographic fields
-- ============================================================================
WITH base_query AS (
    SELECT
        f.order_number,                         -- Unique order identifier
        f.product_key,                          -- Product reference
        f.order_date,                           -- Date of transaction
        f.sales_amount,                         -- Revenue per transaction
        f.quantity,                             -- Quantity sold per order
        c.customer_key,                         -- Customer surrogate key
        c.customer_number,                      -- Business-facing customer ID
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,  -- Full name
        DATEDIFF(year, c.birthdate, GETDATE()) AS age             -- Derived age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL
)

-- ============================================================================
-- CTE #2: Customer Aggregation - Summarize at customer level
-- ============================================================================
, customer_aggregation AS (
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,    -- # of unique orders
        SUM(sales_amount) AS total_sales,                -- Total revenue
        SUM(quantity) AS total_quantity,                 -- Total items purchased
        COUNT(DISTINCT product_key) AS total_products,   -- # of unique products
        MAX(order_date) AS last_order_date,              -- Most recent purchase date
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan -- Duration (months)
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)

-- ============================================================================
-- STEP 3: Final Output - Segment customers and compute key KPIs
-- ============================================================================
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    -- --------------------------
    -- Age Segmentation
    -- --------------------------
    CASE 
         WHEN age < 20 THEN 'Under 20'
         WHEN age BETWEEN 20 AND 29 THEN '20-29'
         WHEN age BETWEEN 30 AND 39 THEN '30-39'
         WHEN age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50 and above'
    END AS age_group,

    -- --------------------------
    -- Customer Segment Definition
    -- --------------------------
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'Ne
