/*
===============================================================================
Title: Cumulative Analysis Script
Author: Chinedu Anele
Role: Data Engineer
Date: 2025-11-09
===============================================================================
Purpose:
    - To compute running totals and moving averages across time for key metrics.
    - To observe cumulative growth and long-term performance trends.
    - Often used for tracking revenue growth, progressive KPIs, or retention trends.

Tables Referenced:
    - gold.fact_sales

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
    - Aggregation: SUM(), AVG()
===============================================================================
*/

-- Calculate total sales per year along with cumulative (running) total sales
-- and moving average of price over time.
-- This helps visualize progressive business performance and identify growth patterns.
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,   -- Running cumulative sales
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price      -- Moving average of product price
FROM
(
    -- Aggregate sales and price at the yearly level
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t;
