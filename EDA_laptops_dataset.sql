USE sql_projects;
SELECT * FROM laptopdata;

-- CREATING ID COLUMN
ALTER TABLE laptopdata ADD COLUMN id INTEGER;
ALTER TABLE laptopdata MODIFY COLUMN id INT FIRST;
ALTER TABLE laptopdata MODIFY COLUMN id INT AUTO_INCREMENT PRIMARY KEY;
SELECT * FROM laptopdata;

-- NUMERICAL COLUMNS
-- head,tail and sample
SELECT * FROM laptopdata
order by `id` limit 5;

SELECT * FROM laptopdata
order by `id` DESC limit 5;

SELECT * FROM laptopdata
order by rand() LIMIT 5;

-- calculating count,min,max,avg,std for numerical column
SELECT COUNT(Price),
	MIN(Price),
	MAX(Price),
	AVG(Price),
	STD(Price)
FROM laptopdata;
-- 1270(count), 9271(min), 324955(max), 59919.1047(avg), 37305.889950885976(std)

-- Calculating Q1,Q2,Q3 PERCENTILES 

WITH ordered AS (
    SELECT Price,
           ROW_NUMBER() OVER (ORDER BY Price) AS row_num,
           COUNT(*) OVER () AS total_rows
    FROM laptopdata
)
SELECT 
    (SELECT Price FROM ordered WHERE row_num = FLOOR(total_rows * 0.25)) AS Q1,
    (SELECT Price FROM ordered WHERE row_num = FLOOR(total_rows * 0.50)) AS Q2, -- Median
    (SELECT Price FROM ordered WHERE row_num = FLOOR(total_rows * 0.75)) AS Q3
FROM ordered
LIMIT 1;
-- Q1:31915, Q2:52055, Q3:79215

-- missing value
SELECT COUNT(Price)
FROM laptopdata
WHERE Price IS NULL;
# no missing values in price column

-- outliers
WITH ordered AS (
    SELECT Price,
           ROW_NUMBER() OVER (ORDER BY Price) AS row_num,
           COUNT(*) OVER () AS total_rows
    FROM laptopdata
),
Quartiles AS (
    SELECT 
        (SELECT Price FROM ordered WHERE row_num = FLOOR(total_rows * 0.25)) AS Q1,
        (SELECT Price FROM ordered WHERE row_num = FLOOR(total_rows * 0.75)) AS Q3
    FROM ordered
    LIMIT 1
)
SELECT *
FROM laptopdata, Quartiles
WHERE Price < Q1 - 1.5 * (Q3 - Q1) 
   OR Price > Q3 + 1.5 * (Q3 - Q1);-- 28 rows will be returned
   
-- HISTOGRAM:
WITH Buckets AS (
    SELECT Price,
           CASE 
               WHEN price BETWEEN 0 AND 25000 THEN '0-25K'
			   WHEN price BETWEEN 25001 AND 50000 THEN '25K-50K'
			   WHEN price BETWEEN 50001 AND 75000 THEN '50K-75K'
               WHEN price BETWEEN 75001 AND 100000 THEN '75K-100K'
               ELSE '>100K'
           END AS bucket
    FROM laptopdata
)
SELECT bucket,
    Repeat('*', COUNT(*)/10) AS frequency
FROM Buckets
GROUP BY bucket
ORDER BY bucket;

-- UNIVARIATE ANALYSIS
-- value counts(use charts by converting the output)

SELECT Company,
	Count(Company),
	CONCAT(ROUND((COUNT(Company) * 100.0 / (SELECT COUNT(*) FROM laptopdata)), 2),'%') AS percentage
FROM laptopdata
GROUP BY Company
order by COUNT(Company) desc;

SELECT TypeName,
    COUNT(TypeName) AS count,
    CONCAT(ROUND(COUNT(TypeName) * 100 / (SELECT COUNT(*) FROM laptopdata), 2), '%') AS percentage
FROM laptopdata
GROUP BY TypeName;

SELECT COUNT(Inches),
  MIN(Inches),
  MAX(Inches),
  AVG(Inches),
  STD(Inches)
FROM laptopdata;

SELECT COUNT(*) FROM laptopdata
WHERE Inches BETWEEN 15 AND 15.2;

SELECT Touchscreen,
    COUNT(Touchscreen) AS count,
    CONCAT(ROUND(COUNT(Touchscreen) * 100 / (SELECT COUNT(*) FROM laptopdata), 2), '%') AS percentage
FROM laptopdata
GROUP BY Touchscreen;

SELECT cpu_brand,
	Count(cpu_brand),
    CONCAT(ROUND(COUNT(cpu_brand) * 100 / (SELECT COUNT(*) FROM laptopdata), 2), '%') AS percentage
FROM laptopdata
GROUP BY cpu_brand;

SELECT cpu_name,
	Count(cpu_name),
    CONCAT(ROUND(COUNT(cpu_name) * 100 / (SELECT COUNT(*) FROM laptopdata), 2), '%') AS percentage
FROM laptopdata
GROUP BY cpu_name
order by 2 desc;

SELECT COUNT(cpu_speed),
  MIN(cpu_speed),
  MAX(cpu_speed),
  AVG(cpu_speed),
  STD(cpu_speed)
FROM laptopdata;

SELECT DISTINCT Ram FROM laptopdata;
SELECT COUNT(Ram),
  MIN(Ram),
  MAX(Ram),
  AVG(Ram),
  STD(Ram)
FROM laptopdata;

SELECT MemoryType,
	COUNT(MemoryType),
    CONCAT(ROUND(COUNT(MemoryType) * 100 / (SELECT COUNT(*) FROM laptopdata), 2), '%') AS percentage
FROM laptopdata
GROUP BY MemoryType
ORDER BY 2 DESC;

SELECT COUNT(PrimaryStorage),
  MIN(PrimaryStorage),
  MAX(PrimaryStorage),
  AVG(PrimaryStorage),
  STD(PrimaryStorage)
FROM laptopdata;

SELECT PrimaryStorage AS ModeValue -- most frequently occuring value For PrimaryStorage
FROM laptopdata
GROUP BY PrimaryStorage
ORDER BY COUNT(PrimaryStorage) DESC
LIMIT 1;

SELECT COUNT(*) AS CountSecondaryStorage
FROM laptopdata
WHERE SecondaryStorage != 0; -- 204 LAPTOPS HAS SECONDARY STORAGE AND 1066 DOESNT HAVE

SELECT SecondaryStorage, 
	COUNT(SecondaryStorage) AS Frequency,
    CONCAT(ROUND(COUNT(SecondaryStorage) * 100 /(SELECT COUNT(*) FROM laptopdata),2),'%') AS Percentage
FROM laptopdata
WHERE SecondaryStorage > 0
GROUP BY SecondaryStorage
ORDER BY Frequency DESC;

SELECT gpu_brand,
	COUNT(gpu_brand),
    CONCAT(ROUND(COUNT(gpu_brand) * 100 /(SELECT COUNT(*) FROM laptopdata),2),'%') AS Percentage
FROM laptopdata
GROUP BY gpu_brand
ORDER BY 2 DESC;


SELECT OpSys,
	COUNT(OpSys),
	CONCAT(ROUND(COUNT(OpSys) * 100 /(SELECT COUNT(*) FROM laptopdata),2),'%') AS Percentage
FROM laptopdata
GROUP BY OpSys
ORDER BY 2 DESC;

SELECT * FROM laptopdata
WHERE OpSys = 'NA';

SELECT COUNT(Weight),
  MIN(Weight),
  MAX(Weight),
  AVG(Weight),
  STD(Weight)
FROM laptopdata;


SELECT COUNT(Price),
  MIN(Price),
  MAX(Price),
  AVG(Price),
  STD(Price)
FROM laptopdata;


-- BIVARIATE ANALYSIS
-- numerical - numerical columns

-- 1. price vs weight
SELECT Weight,
       ROUND(AVG(Price)) AS AvgPrice
FROM laptopdata
GROUP BY Weight
ORDER BY Weight;

-- 2. Price vs PrimaryStorage
SELECT PrimaryStorage,
	ROUND(AVG(Price),2) AS AvgPrice
FROM laptopdata
GROUP BY PrimaryStorage
ORDER BY PrimaryStorage;

-- 3. Price vs Ram
SELECT Ram,
	ROUND(AVG(Price),2) AS AvgPrice
FROM laptopdata
GROUP BY Ram
ORDER BY Ram;

-- 4. Price vs cpu_speed
SELECT cpu_speed,
	ROUND(AVG(Price),2) AS AvgPrice
FROM laptopdata
GROUP BY cpu_speed
ORDER BY cpu_Speed;

-- 5. Price vs Inches
SELECT Inches,
	ROUND(AVG(Price),2) AS AvgPrice
FROM laptopdata
GROUP BY Inches
ORDER BY Inches;

-- 6.Primary vs ResolutionHeight/Width
-- CALCULATING PPI
SELECT ROUND(SQRT(ResolutionWidth*ResolutionWidth + ResolutionHeight*ResolutionHeight)/Inches) AS PPI,
	ROUND(AVG(Price),2) AS AvgPrice
FROM laptopdata
GROUP BY PPI
ORDER BY 2 DESC;

-- CATEGORICAL - CATEGORICAL 
-- (Contingency table - stacked bar chart)
-- 1.Company vs TypeName
SELECT DISTINCT Typename from laptopdata;
SELECT Company,
SUM(CASE WHEN TypeName = 'Ultrabook' THEN 1 ELSE 0 END) AS Ultrabook,
SUM(CASE WHEN TypeName = 'Notebook' THEN 1 ELSE 0 END) AS Notebook,
SUM(CASE WHEN TypeName = 'Gaming' THEN 1 ELSE 0 END) AS Gaming,
SUM(CASE WHEN TypeName = '2 in 1 Convertible' THEN 1 ELSE 0 END) AS Convertible,
SUM(CASE WHEN TypeName = 'Workstation' THEN 1 ELSE 0 END) AS Workstation,
SUM(CASE WHEN TypeName = 'Netbook' THEN 1 ELSE 0 END) AS Netbook
FROM laptopdata
GROUP BY Company
ORDER BY Company;


-- 2.Company vs cpu_brand
SELECT Company,
SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS Intel,
SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS AMD,
SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS Samsung
FROM laptopdata
GROUP BY Company;

-- 3. Company vs MemoryType
SELECT DISTINCT MemoryType FROM laptopdata;
SELECT Company,
SUM(CASE WHEN MemoryType = 'HDD' THEN 1 ELSE 0 END) AS 'HDD',
SUM(CASE WHEN MemoryType = 'SSD' THEN 1 ELSE 0 END) AS 'SSD',
SUM(CASE WHEN MemoryType = 'HYBRID' THEN 1 ELSE 0 END) AS 'HYBRID',
SUM(CASE WHEN MemoryType = 'FLASH STORAGE' THEN 1 ELSE 0 END) AS 'FLASH STORAGE'
FROM laptopdata
GROUP BY Company;

-- 4. Company vs gpu_brand
SELECT DISTINCT gpu_brand FROM laptopdata;
SELECT Company,
SUM(CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END) AS 'Intel',
SUM(CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END) AS 'AMD',
SUM(CASE WHEN gpu_brand = 'Nvidia' THEN 1 ELSE 0 END) AS 'Nvidia',
SUM(CASE WHEN gpu_brand = 'ARM' THEN 1 ELSE 0 END) AS 'ARM'
FROM laptopdata
GROUP BY Company;

-- 5. cpu_brand vs gpu_brand
-- cpu_brand: Intel, AMD, Samsung 
-- gpu_brand: Intel, AMD, Nvidia, ARM
SELECT DISTINCT cpu_brand FROM laptopdata;
SELECT cpu_brand,
SUM(CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END) AS Intel,
SUM(CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END) AS AMD,
SUM(CASE WHEN gpu_brand = 'Nvidia' THEN 1 ELSE 0 END) AS Nvidia,
SUM(CASE WHEN gpu_brand = 'ARM' THEN 1 ELSE 0 END) AS ARM
FROM laptopdata
GROUP BY cpu_brand
ORDER BY cpu_brand;


-- Numerical - categorical
-- 1. Company vs Price
SELECT Company, 
	ROUND(AVG(Price),2) as AvgPrice,
    MIN(Price), 
	MAX(Price),
    COUNT(*) AS COUNT
FROM laptopdata
GROUP BY Company
ORDER BY 2 DESC;

-- 2. gpu_brand vs Price
SELECT gpu_brand, 
	ROUND(AVG(Price),2) as AvgPrice,
    MIN(Price), 
	MAX(Price),
    COUNT(*) AS COUNT
FROM laptopdata
GROUP BY gpu_brand
ORDER BY 2 DESC;

-- 3. OpSys vs Price
SELECT OpSys, 
	ROUND(AVG(Price),2) as AvgPrice,
    MIN(Price), 
	MAX(Price),
    COUNT(*) AS COUNT
FROM laptopdata
GROUP BY OpSys
ORDER BY 2 DESC;

-- 4. TypeName vs Price
SELECT TypeName, 
	ROUND(AVG(Price),2) as AvgPrice,
    MIN(Price), 
	MAX(Price),
    COUNT(*) AS COUNT
FROM laptopdata
GROUP BY TypeName
ORDER BY 2 DESC;

-- 5. cpu_brand vs Price
SELECT 	cpu_brand, 
	ROUND(AVG(Price),2) as AvgPrice,
    MIN(Price), 
	MAX(Price),
    COUNT(*) AS COUNT
FROM laptopdata
GROUP BY cpu_brand
ORDER BY 2 DESC;

-- 6. Touchscreen vs Price
SELECT Touchscreen, 
	ROUND(AVG(Price),2) as AvgPrice,
    MIN(Price), 
	MAX(Price),
    COUNT(*)
FROM laptopdata
GROUP BY Touchscreen
ORDER BY 2 DESC;


