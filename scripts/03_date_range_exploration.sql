/*
===============================================================================
Title: Date Range Exploration Script
Author: Chinedu Anele
Role: Data Engineer
Date: 2025-11-09
===============================================================================
Purpose:
    - Determine the temporal boundaries of key data points in the data warehouse.
    - Understand the historical range of sales and customer data.
    - Provide insights on data completeness and coverage over time.

Tables Referenced:
    - gold.fact_sales
    - gold.dim_customers

SQL Functions Used:
    - MIN()
    - MAX()
    - DATEDIFF()

Usage Notes:
    - This script is read-only and does not modify any data.
    - Execute in SQL Server Management Studio (SSMS) or equivalent.
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
-- Useful for understanding the historical coverage of sales transactions
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
-- Provides insights on customer age distribution
SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;
