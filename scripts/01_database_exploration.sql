/*
===============================================================================
Title: Database Exploration Script
Author: Chinedu Anele
Role: Data Engineer
Date: 2025-11-09
===============================================================================
Purpose:
    - Explore the structure of the 'DataWarehouseAnalytics' database.
    - Retrieve a list of all tables and their schemas.
    - Inspect columns and metadata for specific tables.

Tables Referenced:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS

Usage Notes:
    - This script is read-only and does not modify any data.
    - Execute in SQL Server Management Studio (SSMS) or equivalent.
===============================================================================
*/

-- Retrieve a list of all tables in the database
-- Includes catalog, schema, table name, and table type
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;

-- Retrieve all columns and metadata for the 'dim_customers' table
-- Includes column name, data type, nullability, and maximum character length
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
