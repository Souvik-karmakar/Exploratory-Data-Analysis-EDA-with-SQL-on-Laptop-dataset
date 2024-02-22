#EDA
use EDA;
#Step1:- head -> tail -> sample
#head
select * from laptops
order by `index` LIMIT 5;
#tail
select * from laptops
order by `index` DESC LIMIT 5;
#Random
select * from laptops
order by rand() LIMIT 5;

#Step2:- Numerical columns
#8 no summary
SELECT COUNT(Price) OVER(),
MIN(Price) OVER(),
MAX(Price) OVER(),
AVG(Price) OVER(),
STD(Price) OVER()
FROM laptops
ORDER BY `index` LIMIT 1;

SELECT
    (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Price) FROM laptops) AS Q1,
    (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Price) FROM laptops) AS Median,
    (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Price) FROM laptops) AS Q3
FROM laptops
ORDER BY `index` LIMIT 1;


#Missing values
SELECT COUNT(Price)
FROM laptops
WHERE Price IS NULL;

SELECT COUNT(Company)
FROM laptops
WHERE Company IS NULL;

SELECT COUNT(TypeName)
FROM laptops
WHERE TypeName IS NULL;

SELECT COUNT(Inches)
FROM laptops
WHERE Inches IS NULL;

-- Checking for outliers
SELECT * FROM (SELECT *,
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q1',
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q3'
FROM laptops) t
WHERE t.Price < t.Q1 - (1.5*(t.Q3 - t.Q1)) OR
t.Price > t.Q3 + (1.5*(t.Q3 - t.Q1));

#Univariate analysis
-- Bucketing for Histogram
SELECT t.buckets,REPEAT('*',COUNT(*)/5) FROM (SELECT price,
CASE
WHEN price BETWEEN 0 AND 25000 THEN '0-25K'
WHEN price BETWEEN 25001 AND 50000 THEN '25K-50K'
WHEN price BETWEEN 50001 AND 75000 THEN '50K-75K'
WHEN price BETWEEN 75001 AND 100000 THEN '75K-100K'
ELSE '>100K'
END AS 'buckets'
FROM laptops) t
GROUP BY t.buckets;

#Checking count for each company
SELECT Company,COUNT(Company) FROM laptops
GROUP BY Company order by count(*) desc;

#cpu_speed vs price
SELECT cpu_speed,Price FROM laptops;
select * from laptops;

#Touchscreen laptop count by each company
select Company,
sum(case when Touchscreen=1 then 1 else 0 end) AS 'Touchscreen_yes',
sum(case when Touchscreen=0 then 1 else 0 end) AS 'Touchscreen_no'
from laptops
group by Company;

select DISTINCT cpu_brand from laptops;

#Cpu_brand vs company
select Company,
sum(case when cpu_brand='Intel' then 1 else 0 end) as INTEL,
sum(case when cpu_brand='AMD' then 1 else 0 end)AS AMD ,
sum(case when cpu_brand='Samsung' then 1 else 0 end)AS Samsung
from laptops
group by Company;

-- Categorical Numerical Bivariate analysis
SELECT Company,MIN(price),
MAX(price),AVG(price),STD(price)
FROM laptops
GROUP BY Company;

-- Dealing with missing values
SELECT * FROM laptops
WHERE price IS NULL;

-- replace missing values with mean of price
UPDATE laptops l1
JOIN (
    SELECT `index`, AVG(price) AS avg_price
    FROM laptops
    GROUP BY `index`
) l2 ON l1.`index` = l2.`index`
SET l1.price = IFNULL(l1.price, l2.avg_price);


-- replace missing values with mean price of corresponding company
UPDATE laptops l1
JOIN (
    SELECT Company, AVG(price) AS avg_price
    FROM laptops
    GROUP BY Company
) l2 ON l1.Company = l2.Company
SET l1.price = IFNULL(l1.price, l2.avg_price)
WHERE l1.price IS NULL;


SELECT * FROM laptops
WHERE price IS NULL;

-- corresponsing company + processor
SELECT * FROM laptops;

-- Feature Engineering
ALTER TABLE laptops ADD COLUMN ppi INTEGER;
UPDATE laptops
SET ppi = ROUND(SQRT(resolution_width*resolution_width +
resolution_height*resolution_height)/Inches);

SELECT * FROM laptops
ORDER BY ppi DESC;

#Creating new feature screen size
ALTER TABLE laptops ADD COLUMN screen_size VARCHAR(255) AFTER Inches;

UPDATE laptops
SET screen_size =
CASE
WHEN Inches < 14.0 THEN 'small'
WHEN Inches >= 14.0 AND Inches < 17.0 THEN 'medium'
ELSE 'large'
END;

-- Avg(price) by screen_size
SELECT screen_size,AVG(price) FROM laptops
GROUP BY screen_size;


-- One Hot Encoding
SELECT gpu_brand,
CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END AS 'intel',
CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END AS 'amd',
CASE WHEN gpu_brand = 'nvidia' THEN 1 ELSE 0 END AS 'nvidia',
CASE WHEN gpu_brand = 'arm' THEN 1 ELSE 0 END AS 'arm'
FROM laptops









