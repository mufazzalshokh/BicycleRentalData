# Bicycle Rental Data Warehouse

ASPEX Data Engineer Assessment - Complete Solution

## Overview
This project demonstrates core data engineering concepts through building
a complete data warehouse for a bicycle rental business.

## What's Included
- Schema design with 7 normalized tables
- 11 schema improvements with business rationale
- 5 analytical queries (multi-table joins, aggregations, window functions)
- Bonus data mart with complex calculated column
- Automated ETL procedure with monthly scheduling strategy

## Key Features
- Designed for scalability and data quality
- Business logic implemented at database layer
- Multiple automation approaches documented
- Comprehensive test data for validation

## To Use This
1. Restore backup: `BicycleRental_Backup.bak`
2. Execute scripts in order: 01 → 05
3. Run analytical queries: `sql/04_analytical_queries.sql`
4. Test bonus procedure: `EXEC sp_LoadBonusDataMart`

## Technologies
- SQL Server 2022
- T-SQL
- Data modeling, ETL, Analytics
