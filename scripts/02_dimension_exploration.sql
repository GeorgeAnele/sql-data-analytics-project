/*
===============================================================================
Title: Dimensions Exploration Script
Author: Chinedu Anele
Role: Data Engineer
Date: 2025-11-09
===============================================================================
Purpose:
    - Explore the structure and distinct values of dimension tables in the 
      'DataWarehouseAnalytics' warehouse.
    - Identify unique countries, product categories, subcategories, and product names.

Tables Referenced:
    - gold.dim_customers
    - gold.dim_products

SQL Functions Used:
    - DISTINCT
    - ORDER BY

Usage Notes:
    - This script is read-only and safe for execution in the production database.
    - Execute in SQL Server Management Studio (SSMS) or equivalent.
===============================================================================
*/

-- Retrieve a list of unique countries from which customers originate
-- Helps to understand the customer base distribution
SELECT DISTINCT 
    country 
FROM gold.dim_customers
ORDER BY country;

-- Retrieve a list of unique product categories, subcategories, and product names
-- Useful for understanding product hierarchy and inventory coverage
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM gold.dim_products
ORDER BY category, subcategory, product_name;
