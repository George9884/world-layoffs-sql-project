-- WORLD LAYOFFS PROJECT - END TO END ANALYSIS
-- Author: George Abasiumoh | Tools: MySQL
-- Dataset: 2020-2023 Global Tech Layoffs


SELECT*
FROM layoffs;

USE world_layoffs;

-- PHASE 1: DATA CLEANING
-- Goal: Make raw data usable without touching original


-- 1.1 Create staging table
DROP TABLE IF EXISTS layoffs_staging;
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT layoffs_staging 
SELECT * 
FROM layoffs;

-- 1.2 Remove Duplicates using ROW_NUMBER()
DROP TABLE IF EXISTS layoffs_staging2;
CREATE TABLE layoffs_staging2 LIKE layoffs_staging;
ALTER TABLE layoffs_staging2 ADD row_num INT;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

DELETE FROM layoffs_staging2 WHERE row_num > 1;
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;

-- 1.3 Standardize and Remove Nulls
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- 1.4 Fix Date Column: Convert TEXT '1/10/2020' to DATE '2020-01-10'
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- ==========================================
-- PHASE 2: EXPLORATORY DATA ANALYSIS (EDA)
-- Goal: Answer business questions
-- ==========================================

-- Q1: Biggest single layoff and companies that closed 100%
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT company, total_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Q2: Total layoffs by Company, Country, Stage
SELECT company, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_off DESC;

SELECT country, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_off DESC;

SELECT stage, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_off DESC;

-- Q3: Date range of data
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Q4: Monthly layoffs + Rolling Total
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `MONTH`
ORDER BY `MONTH` ASC;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `MONTH`
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Q5: Top 5 Companies with most layoffs each Year (Advanced - CTE + DENSE_RANK)
WITH company_Year AS
(
SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),
company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking 
FROM company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM company_Year_Rank 
WHERE Ranking <= 5;