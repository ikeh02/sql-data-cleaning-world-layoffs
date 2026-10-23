-- Importing your data into my sql

SELECT * FROM world_layoffs.layoffs;
  
  -- Next altering a raw or main data is not clinical so it is best you create anoter table staging the main data and work on it
  create table layoff_learner
  like world_layoffs.layoffs;
  
  
  select *
  from layoff_learner;
  
  -- After creating  the table you insert the datasets from the real table into the stagging table
  insert layoff_learner
  select *
  from  world_layoffs.layoffs;
  
  -- DATA CLEANING PROCEDURES
  -- 1. Remove duplicates
  -- 2. standardize the data
  -- 3. Remove nulls and blanks
  
  -- removing duplicates
   -- asign to each row a row_number
  
  select*,
  row_number () over (
  partition by company, location, industry, total_laid_off, percentage_laid_off , `date`, stage , country, funds_raised_millions
  ) as row_num
  from layoff_learner;
  
  
  select *
  from layoff_learner
  where company = 'casper';
  
  -- use cte_example to know the rows that are > 1 since row numbers assigns a specific number to a row so if it is greater than 1 then it is a duplicate
 
 with cte_duplicate as 
  (
  select*,
  row_number () over (
  partition by company, location, industry, total_laid_off, percentage_laid_off , `date`, stage , country, funds_raised_millions
  ) as row_num
  from layoff_learner
  )
  select*
   from cte_duplicate
   where row_num > 1;
  
  
  -- Next since we used a query to get row numbers , now wil create a table and add row_number to be in actual column by copying the create statement from your staging table and adding your column
  
  
  CREATE TABLE `layoff_learner2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- After creating the table then inserted the data for the column 
  
  insert into layoff_learner2
   select*,
  row_number () over (
  
  partition by 
					company, 
					  location, 
					  industry, 
					  total_laid_off, 
					  percentage_laid_off , 
					  `date`, 
					  stage , 
					  country, 
					  funds_raised_millions
  ) as row_num
  from layoff_learner;
  
  
 delete
   from layoff_learner2
   where row_num > 1;
  
  
  select*
   from layoff_learner2
   where row_num > 1;
   
   
   select*
from layoff_learner2
where company = 'airbnb';


--  Noticed that the data had some spaces making it count as a duplicate so i dropped the table


DROP TABLE IF EXISTS layoff_learner2;

-- created another table while trimming the data


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


-- Delete every duplicate by deleting any row number greater than 1
delete
   from layoff_learner2
   where row_num > 1;
   
   
  
  select*
   from layoff_learner2
   where company = 'airbnb';
   
   -- standardizing data
   
   -- Notice some spaces in company column then i trimmed
   
   select company, trim(company)
   from layoff_learner2;
   
   update layoff_learner2
   set company = trim(company);
   
   select*
    from layoff_learner2;
    
    -- In the industry column  same industries where not bearing same name so i made sure they were same 
    
    select distinct industry
     from layoff_learner2;
     
     select *
      from layoff_learner2
      where industry like 'crypto%';
      
      
      update layoff_learner2
      set industry = 'crypto'
      where industry like 'crypto%';
      
      
      select distinct location
      from layoff_learner2;
      
      
      -- here there was a punctuation in a country making same countries seem different so it was removed
     
     select distinct country,
      trim( trailing '.' from country)
      from layoff_learner2
       ;
       
       update layoff_learner2
       set country =  trim( trailing '.' from country)
       where country like 'united states%';
       

      
      select*
      from layoff_learner2
      where country like 'united states%';
      
      
      select distinct country
      from  layoff_learner2
      order by 1;
      
      
      select *
      from  layoff_learner2;
      
      -- The date what not in write order so i put it in the write order
      
      select `date`,
      str_to_date( `date`, '%m/%d/%Y')
      from  layoff_learner2;
      
      -- The date data was in text format instead of date so i altered the table to modify the column to a date format
     alter table layoff_learner2
     modify column `date` date;
      
       -- Removing nulls and blanks
       
      select*
      from layoff_learner2
      where total_laid_off is null
      and percentage_laid_off is null;
      
      select *
      from layoff_learner2
      where industry is null
      or industry = '';
      
      select *
      from layoff_learner2
      where company = 'airbnb';
       
       update layoff_learner2
       set industry =null
       where industry = '';
       
       -- Filling up blank spaces by prepopulating or populating it where it is same
       
       select *
      from layoff_learner2 tb1
      join layoff_learner2 tb2
		on tb1.company=tb2.company
        and tb1.location=tb2.location
        where ( tb1.industry is null or tb1.industry = '')
        and tb2.industry is not null;
      
             select tb1.industry , tb2.industry
      from layoff_learner2 tb1
      join layoff_learner2 tb2
		on tb1.company=tb2.company
        where ( tb1.industry is null )
        and tb2.industry is not null;
        
        
        update layoff_learner2 tb1
         join layoff_learner2 tb2
		on tb1.company=tb2.company
        set tb1.industry = tb2.industry
        where (tb1.industry is null)
        and tb2.industry is not null;
        
        
        
        select*
        from layoff_learner2;
        
        
      select*
      from layoff_learner2
      where total_laid_off is null
      and percentage_laid_off is null;
      
      -- deleted the nulls 
      
     delete
      from layoff_learner2
      where total_laid_off is null
      and percentage_laid_off is null;
      
      select*
        from layoff_learner2;
        
        -- Removed the row number column after working with it because it was not part of the data
        
        alter table layoff_learner2
        drop column row_num;
      
      
      