/*
===============================================================================
Title: Measures Exploration (Key Metrics) Script
Author: Chinedu Anele
Role: Data Engineer
Date: 2025-11-09
===============================================================================
Purpose:
    - Calculate aggregated metrics (e.g., totals, averages) for quick business insights.
    - Identify overall trends, track performance, and spot potential anomalies.

Tables Referenced:
    - gold.fact_sales
    - gold.dim_products
    - gold.dim_customers

SQL Functions Used:
    - COUNT()
    - SUM()
    - AVG()

Usage Notes:
    - This script is read-only and does not modify any data.
    - Execute in SQL Server Management Studio (SSMS) or equivalent.
===============================================================================
*/

-- Calculate the total sales amount across all orders
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

-- Calculate the total quantity of items sold
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales

-- Calculate the average selling price of items
SELECT AVG(price) AS avg_price FROM gold.fact_sales

-- Count the total number of orders
SELECT COUNT(order_number) AS total_orders FROM gold.fact_sales
-- Count the total number of distinct orders
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales

-- Count the total number of products
SELECT COUNT(product_name) AS total_products FROM gold.dim_products

-- Count the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;

-- Count the total number of customers that have placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales;

-- Generate a consolidated report showing all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers;
