CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
    inovice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch varchar(5) not null,
    city varchar(30) not null, 
    customer_type varchar(30) not null, 
    gender varchar(10) not null,
    product_line varchar(100) not null, 
    unit_price decimal(10, 2) not null,
    quantity int not null, 
    VAT FLOAT(6,4) NOT NULL, 
    total decimal(12, 4) not null, 
    Date DATETIME NOT NULL, 
    TIME TIME NOT NULL,
    payment_method varchar(15) Not null,
    cogs decimal(10,2) not null, 
    gross_marging_pct float(11,9),
    gross_income decimal(12, 4) not null, 
    rating float(2,1)
);

select*from salesdatawalmart.sales;

-- feature engineering

SET SQL_SAFE_UPDATES = 0;

 
SELECT inovice_id, TIME,
       CASE 
           WHEN TIME BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
           WHEN TIME BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
           ELSE 'Evening'
       END AS time_of_day
FROM sales
LIMIT 10;

ALTER TABLE sales CHANGE `TIME` sale_time TIME NOT NULL;

UPDATE sales
SET time_of_day = (
    CASE 
        WHEN time(sale_time) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN TIME(sale_time) BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END
);



SELECT inovice_id, sale_time, time_of_day
FROM sales
LIMIT 10;


-- day_name

SELECT 
     date,
     DAYNAME(date)
from sales;

ALTER TABLE sales ADD COLUMN day_name Varchar(10);

update sales 
set day_name = dayname(date);

-- month_name 

select 
    date, 
    monthname(date)
from sales;


alter table sales add column month_name VARCHAR(10);

UPDATE sales 
set month_name = monthname(date);
--------------------------------------------------------------------------------------------
-- GENERIC--

-- HOW MANY UNIQUE CITIES DOES THE DATA HAVE?
SELECT 
    DISTINCT city 
from sales;

-- IN WHICH CITY IS EACH BRANCH PRESENT 

SELECT 
      DISTINCT city,
      branch 
from sales;

---------------------------------------------------------------------------------------------
-- product--
-- HOW MANY UNIQUE PRODUCT LINES DOES THE DATA HAVE?
select 
    count(distinct product_line) 
from sales;

-- WHAT IS THE MOST COMMON PAYMENT METHOD?
Select 
  payment_method,
  count(payment_method) as cnt
 from sales
 group by payment_method
 order by cnt desc;
 
 -- WHAT IS THE MOST SELLING PRODUCT LINE?
 select 
  product_line, 
  count(product_line) as cnt
  from sales 
  group by product_line 
  order by cnt desc;
  
  -- WHAT IS THE TOTAL REVENUE BY MONTH?
  SELECT 
   month_name as month,
   sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc;

-- WHAT MONTH HAD THE LARGEST COGS?
 
SELECT 
     month_name as month, 
     SUM(cogs) as cogs 
from sales
group by month_name
order by cogs;

-- WHAT PRODUCT LINE HAD THE LARGEST REVENUE?

SELECT 
product_line, 
sum(total) as total_revenue 
from sales 
group by product_line 
order by total_revenue desc;

-- WHAT IS THE CITY WITH THE LARGEST REVENUE?

SELECT 
branch,
city, 
sum(total) as total_revenue 
from sales 
group by city, branch
order by total_revenue desc;

-- WHAT PRODUCT LINE HAD THE LARGEST VAT?
SELECT 
product_line, 
avg(vat) as avg_tax 
from sales 
group by product_line
order by avg_tax desc;

-- WHICH BRANCH SOLD MORE PRODUCTS THAN AVERAGE PRODUCT SOLD?
SELECT 
 branch, 
 sum(quantity) as qty 
 from sales 
 group by branch
 having sum(quantity) > (select avg(quantity) from sales);

-- WHAT IS THE MOST COMMON PRODUCT LINE BY GENDER?
SELECT 
 gender, 
 product_line, 
 count(gender) as total_cnt
from sales 
group by gender, product_line 
order by total_cnt desc;

-- WHAT IS THE AVERAGE RATING OF EACH PRODUCT LINE?
SELECT 
 ROUND(AVG(rating), 2) as avg_rating, 
 product_line 
 from sales 
 group by product_line 
 order by avg_rating desc;
----------------------------------------------------------------------------------------------
-- SALES--

-- Number of sales made in each time of the day per weekday 
select 
time_of_day,
count(*) as total_sales
from sales 
where day_name = 'Sunday'
group by time_of_day 
order by total_sales desc;

-- Which of the customer types brings the most revenue?
Select 
	customer_type,
    SUM(total) AS total_rev
from sales
group by customer_type 
order by total_rev desc;
 
 -- Which city has the largest tax percent/ VAT (VALUE ADDED TAX)?
 Select 
	city, 
    AVG(VAT) AS VAT
 from sales
 GROUP BY city
 order by VAT DESC;
 
 -- which customer type pays the most in VAT?
  Select 
	customer_type, 
    AVG(VAT) AS VAT
 from sales
 GROUP BY customer_type
 order by VAT DESC;
 
 ----------------------------------------------------------------------------------------------
 -- CUSTOMER -- 
 
 -- How many unique customers does the data have?
 SELECT 
	distinct customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT 
	distinct payment_method
from sales;
 
 -- Which customer type buys the most?
 SELECT 
	customer_type,
    count(*) as cstm_cnt
from sales
group by customer_type;

-- What is the gender of most of the customers?
SELECT 
	gender, 
    count(*) as gender_cnt
from sales
group by gender
order by gender_cnt;

-- what is the gender distribution per branch?
SELECT 
	gender, 
    count(*) as gender_cnt
from sales 
where branch = 'A'
GROUP BY gender 
ORDER BY gender_cnt DESC;

-- What time of the day do customers give most ratings?
SELECT
	time_of_day,
    AVG(rating) as avg_rating
from sales 
where branch = 'A'
Group by time_of_day
order by avg_rating desc;

-- Which day of the week has the best avg ratings?
SELECT 
	day_name, 
    AVG(rating) as avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best ratings per branch?
SELECT 
	day_name, 
    AVG(rating) as avg_rating
FROM sales
WHERE branch = "A"
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Revenue contribution by Product Line and Customer type 
-- * Analyze how each product line contributes to the total revenue for each customer type.
SELECT 
	customer_type, 
    product_line,
    ROUND(SUM(total) / (SELECT SUM(total) FROM sales) *100, 2) AS revenue_pct
  FROM sales
  GROUP BY customer_type, product_line
  Order by revenue_pct desc;

-- Seasonal Trends: Revenue Analysis by Month and Product Line
-- * Identify any seasonal trends by looking at monthly revenue by product line.

SELECT 
	month_name, 
    product_line, 
    SUM(total) as monthly_revenue
FROM sales 
GROUP BY month_name, product_line
ORDER BY month_name, monthly_revenue DESC;
  
  -- Correlation between quantity sold and gross income
  -- * Check if there's correlation between the quantity sold and gross income using a CTE(Common Table Expression).
  
  WITH sales_stats AS(
	SELECT 
		product_line,
        SUM(quantity) as total_quantity,
        SUM(gross_income) as total_income
	FROM sales 
    GROUP BY product_line
)
 SELECT 
	product_line,
    total_quantity,
    total_income,
    ROUND(total_income/ total_quantity, 2) as income_per_unit
FROM sales_stats
ORDER BY income_per_unit DESC;

-- Top 5 Cities with highest average rating
-- Find out which cities receive the best average ratings.

SELECT 
	city, 
    ROUND(AVG(rating), 2) as avg_rating
FROM sales 
GROUP BY city
ORDER BY avg_rating desc
limit 5;

-- Customer retention analysis using payment methods
-- * Identify which payment methods are most popular among repeat customers(assuming repeat customers use the same payment method).

SELECT 
	payment_method, 
    COUNT(DISTINCT inovice_id) as repeat_customers
FROM sales 
WHERE customer_type = 'Member'
GROUP BY payment_method 
ORDER BY repeat_customers desc;

-- Identify potential fraud: Unusally high VAT payments
-- * Flag transactions with unusally high VAT payments as potential fraud.

SELECT 
	inovice_id,
    branch, 
    total,
    VAT, 
    ROUND((VAT/ total)*100,2) AS vat_percentage
FROM sales 
WHERE (VAT/ total) > 0.2
ORDER BY vat_percentage DESC;

-- Revenue Growth Analysis: Month-over-Month comparison 
-- * Analyze revenue growth month-over-month

WITH monthly_revenue AS (
    SELECT 
        month_name,
        SUM(total) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY STR_TO_DATE(month_name, '%M')) AS month_rank
    FROM sales 
    GROUP BY month_name
)
SELECT 
    current_month.month_name AS current_month,
    current_month.total_revenue AS current_revenue,
    previous_month.total_revenue AS previous_revenue,
    ROUND(((current_month.total_revenue - previous_month.total_revenue) / previous_month.total_revenue) * 100, 2) AS growth_pct
FROM monthly_revenue current_month
LEFT JOIN monthly_revenue previous_month
    ON current_month.month_rank = previous_month.month_rank + 1;
    
-- Sales Forecasting Using simple moving average 
-- * Calculate a simple moving average for sales to identify trends.

WITH daily_sales as(
	SELECT 
		DATE(Date) as sales_date,
        SUM(total) AS daily_revenue
	FROM sales
    GROUP BY DATE(date)
),
moving_avg as(
	SELECT 
		sales_date,
        daily_revenue,
        ROUND(AVG(daily_revenue) OVER (ORDER BY sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_avg_revenue
FROM daily_sales
)
SELECT * FROM moving_avg ORDER BY sales_date;

-- CUSTOMER DEMOGRAPHICS: GENDER- WISE average spending
-- * Analyze the average spending per transaction by gender.

SELECT 
	gender, 
    ROUND(AVG(total), 2) AS avg_spending
FROM SALES 
GROUP BY gender
ORDER BY avg_spending DESC;

-- DYNAMIC REVENUE ANALYSIS: revenue contribution by day of the week 
-- * understand which days contribute the most to total revenue. 

SELECT
	day_name,
    ROUND(SUM(total)/(SELECT SUM(total) FROM sales) * 100, 2) AS revenue_contribution_pct
FROM sales
GROUP BY day_name
ORDER BY revenue_contribution_pct desc;    

