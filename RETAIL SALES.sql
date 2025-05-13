select * from ah_practice;
---------------------------------------DATA CLEANING-----------------------------------------------------------------
--check if its null
select * from ah_practice where transactions_id IS NULL;

--check if the columns have any null value
SELECT 'sale_date' AS columnname
WHERE EXISTS (SELECT 1 FROM ah_practice WHERE sale_date IS NULL)
UNION
SELECT 'sale_time'
WHERE EXISTS (SELECT 1 FROM ah_practice WHERE sale_time IS NULL)
UNION
SELECT 'customer_id'
WHERE EXISTS (SELECT 1 FROM ah_practice WHERE customer_id IS NULL)
UNION
SELECT 'gender'
WHERE EXISTS (SELECT 1 FROM ah_practice WHERE gender IS NULL)
UNION
SELECT 'AGE'
WHERE EXISTS (SELECT 1 FROM ah_practice WHERE age IS NULL)
UNION
SELECT 'category'
WHERE EXISTS (SELECT 1 FROM ah_practice WHERE category IS NULL)
UNION
SELECT 'quantiy'
WHERE EXISTS (SELECT 1 FROM ah_practice WHERE quantiy IS NULL) -- fixed typo
UNION
SELECT 'price_per_unit'
WHERE EXISTS (SELECT 1 FROM ah_practice WHERE price_per_unit IS NULL)
UNION
SELECT 'cogs'
WHERE EXISTS (SELECT 1 FROM ah_practice WHERE cogs IS NULL)
UNION
SELECT 'total_sale'
WHERE EXISTS (SELECT 1 FROM ah_practice WHERE total_sale IS NULL);

--SELECTING THE NULL VALUES
SELECT * FROM ah_practice
WHERE 
AGE IS NULL OR 
quantiy IS NULL OR
price_per_unit  IS NULL OR 
cogs IS NULL OR 
total_sale IS NULL;

--ONLY DELETING PRICE,COGS AND TOTALSALE NULL COLUMNS

DELETE FROM ah_practice
WHERE 
price_per_unit  IS NULL OR 
cogs IS NULL OR 
total_sale IS NULL; --3 RECORDS DELETED

--CHECKING THE COUNT
SELECT COUNT(*) FROM ah_practice;


----------------------------------------DATA EXPLORATION------------------------------------------------------------------

--HOW MANY CUSTOMERS
SELECT COUNT(customer_id) FROM ah_practice;

--UNIQUE CUSTOMERS
SELECT COUNT(DISTINCT customer_id) FROM ah_practice;

--CATEGORY (UNIQUE)
SELECT DISTINCT category  FROM ah_practice;


------------------------------------BUSINESS PROBLEMS----------------------------------------------------------------------

-- 2022-11-05 SALES
SELECT * FROM ah_practice WHERE SALE_DATE = '2022-11-05';

--CATEGORY IS CLOTHING THEN QUANTITY IS LESS THAN OR EQUAL TO 4 AND SOLD IN NOV 2022
SELECT * FROM ah_practice WHERE CATEGORY ='CLOTHING' AND quantiy>=4 AND SALE_DATE LIKE '2022-11%';

--TOTAL SALES PER CATEGORY
SELECT  CATEGORY,SUM(TOTAL_SALE)AS TOTAL_SALE,COUNT(*) as total_orders
FROM ah_practice GROUP BY CATEGORY;

--AVG AGE OF CUSTOMERS IN BEAUTY CATEGORY
SELECT ROUND(AVG(AGE),2) AS AVG_AGE FROM ah_practice WHERE CATEGORY ='BEAUTY';

--TRANSACTION GREATER THAN 1000
SELECT * FROM ah_practice WHERE TOTAL_SALE>1000;

--TOTAL SALES PER GENDER AND CATEGORY
SELECT  CATEGORY ,GENDER ,count( distinct transactions_id) as Total_sale
FROM ah_practice 
GROUP BY GENDER,CATEGORY
ORDER BY GENDER,CATEGORY;

--AVG SALE OF EACH MONTH in year 
SELECT MONTH(SALE_DATE) AS MONTH ,AVG(TOTAL_SALE) AS AVG_SALE ,YEAR(SALE_DATE) AS YEAR
FROM ah_practice 
GROUP BY MONTH(SALE_DATE),YEAR(SALE_DATE)
ORDER BY YEAR(SALE_DATE),MONTH(SALE_DATE);

--BEST SELLING MONTH IN EACH YEAR
SELECT Sales_Year, Sales_Month, Total_Monthly_Sale
FROM (
    SELECT 
        YEAR(SALE_DATE) AS Sales_Year,
        MONTH(SALE_DATE) AS Sales_Month,
        SUM(TOTAL_SALE) AS Total_Monthly_Sale,
        ROW_NUMBER() OVER (PARTITION BY YEAR(SALE_DATE) ORDER BY SUM(TOTAL_SALE) DESC) AS rn
    FROM ah_practice
    GROUP BY YEAR(SALE_DATE), MONTH(SALE_DATE)
) AS Ranked
WHERE rn = 1
ORDER BY Sales_Year;



--UNIQUE CUSTOMERS FROM EACH CATEGORY
SELECT CATEGORY,COUNT(DISTINCT CUSTOMER_ID) AS UNIQUE_CUSTOMERS FROM ah_practice
GROUP BY CATEGORY
ORDER BY CATEGORY;

-- top 5 customers based on the highest total sales 
select top 5 
CUSTOMER_ID ,SUM(TOTAL_SALE) AS TOTAL_SALE
FROM ah_practice
GROUP BY customer_id
ORDER BY total_sale DESC;


--query to create each shift and number of orders
WITH QUERY AS(SELECT *,
CASE
	WHEN DATEPART(HOUR, SALE_TIME) < 12 THEN 'MORNING'
    WHEN DATEPART(HOUR, SALE_TIME) BETWEEN 12 AND 17 THEN 'AFTERNOON'
    WHEN DATEPART(HOUR, SALE_TIME) > 17 THEN 'EVENING'
	END AS 'SHIFT'
FROM ah_practice
)SELECT SHIFT,COUNT(*) AS COUNT_SHIFT
FROM QUERY
GROUP BY SHIFT;