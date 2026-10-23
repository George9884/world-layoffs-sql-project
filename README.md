# world-layoffs-sql-project
End-to-end MySQL project: Cleaned global tech layoffs data (2020-2023) and performed EDA to uncover trends by company, country, industry, and year.


**World Layoffs Data Cleaning & EDA - MySQL**


**Project Overview**

Explored global tech layoffs dataset spanning 2020 through 2023 to uncover patterns and trends across various companies, industries, and regions.


**Tools Used**

MySQL Workbench


**Phase 1: Data Cleaning**


 * Built staging tables to safeguard the integrity of raw source data

 * 
 * Addressed duplicate records utilizing ROW_NUMBER() alongside PARTITION BY clauses

 * 
 * Standardized text entries and formatted date values appropriately with STR_TO_DATE()

 * 
 * Filtered out uninformative rows where both total and percentage layoff metrics were missing

 * 
**Phase 2: Exploratory Data Analysis**


 * Identified organizations that experienced complete workforce downsizing

 * 
 * Highlighted leading companies and countries impacted by total layoffs

 * 
 * Tracked monthly layoff trajectories alongside cumulative rolling totals

 * 
 * Analyzed yearly top-tier layoff contributors utilizing Common Table Expressions (CTEs) and DENSE_RANK()
 
   George Abasiumoh - Data Analyst. 
