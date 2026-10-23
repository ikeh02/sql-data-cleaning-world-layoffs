# sql-data-cleaning-world-layoffs
Data cleaning and standardization project on global tech layoffs using MySQL Workbench.
# World Layoffs Data Cleaning (MySQL)

## 📌 Project Overview
This project focuses on cleaning and preparing a raw dataset of global tech company layoffs for downstream exploratory data analysis (EDA). The raw data contained redundant duplicate entries, missing/null values, unstandardized text, and whitespace formatting issues.

## 🛠️ Tools Used
- **Database:** MySQL Workbench
- **Language:** SQL (Window Functions, CTEs, Joins, String Functions)

##  Data Cleaning Steps
1. **Duplicate Removal:** Identified duplicate records using `ROW_NUMBER()` partitioned over key columns. Used `TRIM()` on text fields to strip hidden trailing whitespace that caused false unique entries.
2. **Standardization:** Cleaned company and country names, trimmed whitespace, and unified date formats.
3. **Handling NULL & Blank Values:** Converted empty string spaces into SQL `NULL`s, then populated missing categorical fields (like `industry`) using relational self-joins based on matching company names.
4. **Data Sanitization:** Removed irrelevant or empty rows where essential metrics (`total_laid_off` and `percentage_laid_off`) were completely missing.

##  Code Showcase

### Removing Duplicates with Whitespace Trimming
```sql
CREATE TABLE layoff_learner2 AS
SELECT *,
       ROW_NUMBER() OVER(
           PARTITION BY TRIM(company), 
                        TRIM(location), 
                        TRIM(industry), 
                        total_laid_off, 
                        percentage_laid_off, 
                        `date`, 
                        TRIM(stage), 
                        TRIM(country), 
                        funds_raised_millions
       ) AS row_num
FROM layoffs;

DELETE FROM layoff_learner2
WHERE row_num > 1;

UPDATE layoff_learner2 t1
JOIN layoff_learner2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;
