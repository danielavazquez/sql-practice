CREATE TABLE jobs_in_data (work_year integer, job_title text, job_category text, salary_currency text,
						   salary integer, salary_in_usd integer, employee_residence text, experience_level text,
						  employment_type text, work_setting text, company_location text, company_size text)
						 
SELECT * FROM jobs_in_data

--see how many distinct job categories are in the job_category column
SELECT COUNT(DISTINCT job_category) AS unique_job_categories
FROM jobs_in_data;

--Easy Level:
--1-Retrieve all columns for employees with the job title 'Data Analyst'.
SELECT * FROM jobs_in_data where job_title='Data Analyst'; 

--2-List distinct job categories present in the dataset.
--The SELECT DISTINCT statement is used to return only distinct (different) values.
SELECT DISTINCT job_category FROM jobs_in_data;
SELECT DISTINCT (job_category) as job_category FROM jobs_in_data;


--3-Find the average salary (in USD) for all job categories.
SELECT AVG(salary_in_usd) FROM jobs_in_data; --without assigning any alias to the result column
SELECT AVG(salary_in_usd) as salary_in_usd FROM jobs_in_data; --result column will be named "salary_in_usd" in the output


--Moderate Level:
--1-Identify the top 5 job titles with the highest average salary.
SELECT job_title, AVG(salary_in_usd) as average_salary
FROM jobs_in_data
GROUP BY job_title
ORDER BY average_salary DESC
LIMIT 5;   -- MySQL and PostgreSQL use the LIMIT clause instead of TOP to get the top 5

--2-Calculate the total number of employees for each experience level.

SELECT experience_level, COUNT(*) as count_of_people
FROM jobs_in_data
GROUP BY experience_level

--3-Retrieve the job title and salary for employees with a salary greater than $100,000 USD.
SELECT job_title, salary_in_usd
FROM jobs_in_data
WHERE salary_in_usd > 100000
ORDER BY 2 ASC;  --orders the result set based on the second column specified in the SELECT statement (salary_in_usd) in ascending order (ASC). 

--4-Determine the average salary for each company size.
SELECT company_size, AVG(salary_in_usd) as salary_in_usd FROM jobs_in_data --first select the column you want it to be look up by then expression to be performed
GROUP BY company_size
ORDER BY salary_in_usd DESC, salary_in_usd DESC;
--Hard Level:
--1-Find the company location with the highest average salary for Data Scientists.

SELECT company_location, AVG (salary_in_usd) AS average_salary --make sure all selected columns are aggregated or included in the GROUP BY clause
FROM jobs_in_data
WHERE job_title = 'Data Scientist'
GROUP BY company_location
ORDER BY average_salary DESC
LIMIT 1;

--2-Identify the top 3 job titles with the highest total salary across all companies.
SELECT job_title, SUM (salary_in_usd) AS total_salary
FROM jobs_in_data
GROUP BY job_title
ORDER BY total_salary DESC
LIMIT 3;

--3-Calculate the median salary for each job category.
SELECT job_title, percentile_cont(0.5) WITHIN GROUP (ORDER BY salary_in_usd) AS median_salary --percentile_cont is a sql function
FROM jobs_in_data
GROUP BY job_title;

--4-Retrieve the job title and salary for employees who work in a remote setting and have an experience level of 'Senior'.
SELECT job_title, salary_in_usd
FROM jobs_in_data
WHERE work_setting = 'Remote' AND experience_level = 'Senior'
ORDER BY salary_in_usd DESC;

--5-Find the company size with the highest number of employees.
SELECT company_size, COUNT(*) as total_employees --COUNT(*) counts the number of employees for each unique company size & assignes alias of total_employees
FROM jobs_in_data
GROUP BY company_size --groups data by company size and COUNT(*) function will count the # of employees for each unique company size
ORDER BY total_employees DESC --company size with the highest number of employees will apppear first
LIMIT 1; --only the first row

--6-Calculate the average salary for each job title in the 'Technology' job category.
--this doesn't work

--7-Identify the top 3 companies with the highest total salary payout.
--this doesn't work

--Advanced Level:
--1-Find the job title with the highest salary for employees working in 'Large' companies.
SELECT job_title, AVG(salary_in_usd) AS avg_salary
FROM jobs_in_data
WHERE company_size = 'L'
GROUP BY job_title
ORDER BY avg_salary DESC
Limit 1;

--2-Calculate the salary growth percentage for each job title between the years 2022 and 2023.
SELECT
    job_title,
    ((SUM(CASE WHEN work_year = 2023 THEN salary ELSE 0 END) - SUM(CASE WHEN work_year = 2022 THEN salary ELSE 0 END)) /
    NULLIF(SUM(CASE WHEN work_year = 2022 THEN salary ELSE 1 END), 0)) * 100.0 AS growth_percentage --calcs growth % per job title
FROM jobs_in_data
WHERE work_year IN (2022, 2023)
GROUP BY job_title
ORDER BY growth_percentage DESC;


--3-Determine the company location with the highest average salary for employees with an experience level of 'Mid-Level'.
SELECT company_location, AVG(salary_in_usd) AS avg_salary
FROM jobs_in_data
WHERE experience_level = 'Mid-level'
GROUP BY company_location
ORDER BY avg_salary DESC
Limit 1;

--4-Identify the job title with the highest salary in each job category.
--the inner query looks at each job category separately and ranks the jobs within each category based on their salaries.
--the highest salary getting rank 1, the second highest getting rank 2, and so on.
--this is done using the 'ROW_NUMBER()' function

--for each row in the table, the subquery determines job_category, job_title, and salary
--the rank of the job's salary within its job category 'salary_rank' is calculated by ordering salaries within job cateogry in descending order
--So, if there are 5 jobs in the "Software Engineering" category, for example, the job with the highest salary will have a salary_rank of 1, the second highest will have a rank of 2, and so on.
--In simpler terms, the subquery is assigning a rank to each job within its respective category based on salary, with the highest salary getting rank 1, the next highest getting rank 2, and so forth.
--since there are 10 unique job categories, it takes the #1 rank for each unique job category
SELECT 
    job_category,
    job_title,
    salary_in_usd
-----start subquery
FROM (
    SELECT 
        job_category,
        job_title,
        salary_in_usd, --calculates the row numbers 'salary_rank' within each job category based on desc order of salaries 
						--using ROWNUMBER window function 
	
        ROW_NUMBER() OVER (PARTITION BY job_category ORDER BY salary DESC) AS salary_rank
    FROM 
        jobs_in_data
) AS RankedSalaries    --end inner subquery
WHERE 
    salary_rank = 1;

--5-Calculate the average salary for employees in each company size, considering only those with an 'Advanced' experience level.
SELECT company_size, AVG(salary_in_usd) AS avg_salary
FROM jobs_in_data
WHERE experience_level = 'Senior'
GROUP BY company_size
ORDER BY avg_salary DESC;

--6-Find the job title with the highest salary increase from the year 2022 to 2024.--
--data not available
