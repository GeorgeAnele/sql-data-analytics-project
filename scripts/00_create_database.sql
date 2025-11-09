/*
=============================================================
Title: Data Warehouse Initialization Script
Author: Chinedu Anele
Role: Data Engineer
Date: 2025-11-08
=============================================================
Description:
    This script initializes the 'DataWarehouseAnalytics' environment by:
    - Dropping and recreating the database (if it already exists)
    - Creating the 'gold' schema
    - Creating and populating dimensional and fact tables from external CSV datasets

Purpose:
    To establish a clean and consistent data warehouse structure that supports
    analytical queries and business intelligence workloads.

Usage Notes:
    - Ensure CSV file paths are correct before running.
    - This script should be executed in SQL Server Management Studio (SSMS) 
      with administrative privileges.
    - Data will be permanently deleted if the database already exists.

Revision History:
    v1.0 - Initial creation and dataset load process
=============================================================
*/

USE master;
GO

-- Check if the 'DataWarehouseAnalytics' database exists, then drop it for a clean setup
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create a new 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

-- Switch context to the new database
USE DataWarehouseAnalytics;
GO

-- Create Schemas
CREATE SCHEMA gold;
GO

-- Create customer dimension table under gold schema
CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

-- Create product dimension table under gold schema
CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

-- Create sales fact table under gold schema
CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

-- Clear and reload customer dimension table data from CSV
TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'C:\sql\sql-data-analytics-project\datasets\csv-files\gold.dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

-- Clear and reload product dimension table data from CSV
TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'C:\sql\sql-data-analytics-project\datasets\csv-files\gold.dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

-- Clear and reload fact sales table data from CSV
TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'C:\sql\sql-data-analytics-project\datasets\csv-files\gold.fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO
