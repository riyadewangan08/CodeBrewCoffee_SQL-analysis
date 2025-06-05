---codebrew coffee -- data analysis
--tables:

select* from city;
select * from customers; 
select * from products;
select * from sales;

-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT city_name ,
ROUND((population * 0.25)/1000000,2)
AS coffee_consumers_in_millions ,
city_rank FROM city
ORDER BY coffee_consumers_in_millions DESC



-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT p.product_name, s.total FROM sales AS s
JOIN products AS p
ON p.product_id = s.product_id
GROUP BY p.product_name,s.total 
ORDER BY s.total DESC


SELECT 
	ci.city_name,
	SUM(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON ci.city_id = c.city_id
WHERE 
	EXTRACT(YEAR FROM s.sale_date)  = 2023
	AND
	EXTRACT(quarter FROM s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY total_revenue DESC
	


-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT p.product_name,
COUNT(s.sale_id) AS total_order 
FROM products AS p
RIGHT JOIN sales AS s
ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY (COUNT(s.sale_id)) DESC



-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city and total sale
-- number of customer in each these city

SELECT ci.city_name,SUM(s.total) 
    AS total_sales,
    COUNT(distinct s.customer_id) 
	as total_customer,
    ROUND(sum(s.total)::numeric/
    COUNT(distinct s.customer_id)
    ::numeric,2)
    as avg_sales_amt_percity
    FROM customers as cu
    JOIN city as ci
    on cu.city_id =ci.city_id
    JOIN sales as s
    on cu.customer_id = s.customer_id
    GROUP BY ci.city_name
    ORDER BY sum(s.total) DESC




-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

SELECT 
    ci.city_name,
    ROUND(ci.population * 0.25 / 1000000, 2) 
	AS coffee_consumer_in_millions,
    COUNT(DISTINCT cu.customer_id)
	AS coffee_customer
FROM 
    customers as cu
JOIN 
    city as ci ON cu.city_id = ci.city_id
GROUP BY 
    ci.city_name, ci.population
ORDER BY 
    coffee_consumer_in_millions DESC;



-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT * 
FROM
(
   SELECT 
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) as total_orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name
		ORDER BY COUNT(s.sale_id) DESC) as rank
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY ci.city_name,
		p.product_name
     ) as table1
WHERE rank <= 3




-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT ci.city_name, (count(distinct c.customer_id) ) as unique_customer
FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
WHERE p.product_id in 
(1,2,3,4,5,6,7,8,9,10,11,12,13,14)
GROUP BY ci.city_name
ORDER BY (count(distinct c.customer_id) ) desc



-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

SELECT 
   ci.city_name,
    ci.estimated_rent,
    COUNT(DISTINCT cu.customer_id)
	AS total_customer,
    ROUND(SUM(s.total)::numeric /
	COUNT(DISTINCT cu.customer_id), 2)
	AS avg_sale_per_cx,
    ROUND(ci.estimated_rent::numeric 
	/ COUNT(DISTINCT cu.customer_id), 2)
	AS avg_rent_per_cx
FROM city ci
JOIN customers cu
ON ci.city_id = cu.city_id
JOIN sales s
ON cu.customer_id = s.customer_id
GROUP BY ci.city_name, 
ci.estimated_rent
ORDER BY avg_rent_per_cx DESC;



-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city


WITH 
monthly_sales as(
  select 
    ci.city_name,
	SUM(s.total)AS cust_monthly_sale,
   EXTRACT (MONTH FROM  s.sale_date) as month,
   EXTRACT (YEAR FROM  s.sale_date) as year 
   from customers as cu
   join sales as s
   on cu.customer_id =s.customer_id
   join city as ci
   on ci.city_id=cu.city_id
   GROUP BY 1,3,4
   ORDER BY 1,4,3
),


growth_ratio AS (
  SELECT 
    city_name,
     cust_monthly_sale,
    month,
    year,
    LAG(cust_monthly_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) 
	AS last_month_sale
  FROM monthly_sales
)
SELECT city_name,
cust_monthly_sale,
    month,
	year,
    last_month_sale,
    ROUND((cust_monthly_sale - last_month_sale)
     ::numeric /
     last_month_sale ::numeric*100 ,2)
     as sales_growth_rate
    FROM growth_ratio
     where last_month_sale IS NOT NULL;






-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, average sale, average rent, total customers, estimated coffee consumer


SELECT 
   ci.city_name,
    ci.estimated_rent,
    COUNT(DISTINCT cu.customer_id)
	AS total_customer,
    ROUND(SUM(s.total)
	::numeric /
	COUNT(DISTINCT cu.customer_id), 2)
	AS avg_sale_per_cx,
    ROUND(ci.estimated_rent
	::numeric 
	/ COUNT(DISTINCT cu.customer_id), 2)
	AS avg_rent_per_cx,
	ROUND((ci.population*0.25) /1000000,2)
	AS estimated_coffee_consumers_in_million,
	SUM(s.total)
	as total_revenue
FROM city ci
JOIN customers cu
ON ci.city_id = cu.city_id
JOIN sales s
ON cu.customer_id = s.customer_id
GROUP BY ci.city_name, ci.estimated_rent ,
estimated_coffee_consumers_in_million
ORDER BY avg_sale_per_cx DESC;




/*
---RECOMMENDATION
CITY 1--PUNE
Pune generates the highest total revenue of INR 12,562,920.
- It has a high average sale per customer at INR 24,197.88.
- The estimated coffee consumers in the city are around 1.88 million.
- The average rent is relatively affordable at INR 15,300.
----- With a decent customer base of 52, Pune shows a strong balance between cost, demand, andsales,
       making it the most profitable city.


CITY 2--CHENNAI
- Chennai stands second with total revenue of INR 944,120.
- It has the highest average sale per customer at INR 24,479.05.
- The estimated coffee-consuming population is 2.78 million, which is quite large.
- The customer count is 42, and average rent is INR 17,000.
------Chennai's high spending customers and large audience indicate a high potential for expansion.


CITY3--JAIPUR
- Jaipur also earns a total revenue of INR 944,120, equal to Chennai.
- The average sale per customer is INR 22,054.10.
- It has 39 total customers and an estimated 2.78 million coffee consumers.
- However, the rent is slightly higher at INR 20,700.
------Jaipur shows strong revenue despite higher rent, due to its large consumer base, making it a viable market.






