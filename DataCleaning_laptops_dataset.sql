use sql_projects;
SELECT * FROM laptopdata;

-- create backup
CREATE TABLE laptops_backup LIKE laptopdata;
INSERT INTO laptops_backup
SELECT * FROM laptopdata;

SELECT * FROM laptops_backup;


-- Check no.of rows
SELECT COUNT(*) FROM laptopdata;


-- Check memory consumption for reference
SELECT DATA_LENGTH, DATA_LENGTH/1024 FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'sql_projects'
	AND TABLE_NAME = 'laptopdata';
    

-- Drop non important columns
ALTER TABLE laptopdata
DROP COLUMN `Unnamed: 0`;
SELECT * FROM laptopdata;


-- drop null values(no null values are present in this dataset)
SELECT * FROM laptopdata
WHERE 
    (Unnamed_0 IS NULL OR Unnamed_0 = '') AND
    (Company IS NULL OR Company = '') AND
    (TypeName IS NULL OR TypeName = '') AND
    (Inches IS NULL OR Inches = '') AND
    (ScreenResolution IS NULL OR ScreenResolution = '') AND
    (Cpu IS NULL OR Cpu = '') AND
    (Ram IS NULL OR Ram = '') AND
    (Memory IS NULL OR Memory = '') AND
    (Gpu IS NULL OR Gpu = '') AND
    (OpSys IS NULL OR OpSys = '') AND
    (Weight IS NULL OR Weight = '') AND
    (Price IS NULL OR Price = '');
    
    
-- Drop duplicates
DELETE FROM laptopdata
WHERE (Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price) NOT IN (
    SELECT Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price
    FROM (
        SELECT Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price
        FROM laptopdata
        GROUP BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price
    ) AS grouped_rows
);


-- For column inches ->change column datatype
ALTER TABLE laptopdata MODIFY COLUMN Inches DECIMAL(10,1);
SELECT * FROM laptopdata;

UPDATE laptopdata
SET Ram =REPLACE(Ram,'GB','');
ALTER TABLE laptopdata MODIFY COLUMN Ram INTEGER;

UPDATE laptopdata
SET Weight =REPLACE(Weight,'kg','');

SELECT Weight from laptopdata;
SELECT * FROM laptopdata
where Weight = '?';

UPDATE laptopdata
SET Weight = 1.21
WHERE Weight = '?';

ALTER TABLE laptopdata MODIFY COLUMN Weight DECIMAL(10,2);
select * from laptopdata;

UPDATE laptopdata
SET Price = ROUND(Price);
ALTER TABLE laptopdata MODIFY COLUMN Price INTEGER;

SELECT DISTINCT OpSys FROM laptopdata;
SELECT COUNT(OpSys) FROM laptopdata
where OpSys = 'Chrome OS'; #27

UPDATE laptops l1
SET Price = (SELECT ROUND(Price) 
			FROM laptops l2 WHERE l2.index = l1.index);
            
ALTER TABLE laptops MODIFY COLUMN Price INTEGER;

SELECT DISTINCT OpSys FROM laptops;
-- mac,windows,linux, no os, andrioid & chrome as others

SELECT OpSys,
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'NA'
    ELSE 'other'
END AS 'os_brand'
FROM laptopdata;

UPDATE laptopdata
SET OpSys = 
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'NA'
    ELSE 'other'
END;

SELECT * FROM laptopdata;

-- cleaning column gpu 
ALTER TABLE laptopdata
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu;

SELECT * FROM laptopdata;

UPDATE laptopdata 
SET gpu_brand = SUBSTRING_INDEX(Gpu,' ',1);

ALTER TABLE laptopdata
DROP COLUMN Gpu;
SELECT * FROM laptopdata;

-- cleaning column cpu
ALTER TABLE laptopdata
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

SELECT * FROM laptopdata;

UPDATE laptopdata
SET cpu_brand = SUBSTRING_INDEX(Cpu, ' ', 1),
-- Extracts the brand (e.g., "Intel")
cpu_speed = CAST(REPLACE(SUBSTRING_INDEX(Cpu, ' ', -1), 'GHz', '') AS DECIMAL(10,2)); 
-- Extracts and converts speed (e.g., "2.4")

select * from laptopdata;
-- remove cpu_brand from cpu:
UPDATE laptopdata
SET cpu_name = REPLACE(Cpu, cpu_brand, '');
-- remove cpu_speed from cpu:
UPDATE laptopdata
SET cpu_name = REPLACE(cpu_name, SUBSTRING_INDEX(cpu_name, ' ', -1), '');
-- trim the spaces
UPDATE laptopdata
SET cpu_name = TRIM(cpu_name);
-- drop cpu column
ALTER TABLE laptopdata DROP COLUMN Cpu;

select * from laptopdata;

-- Cleaning ScreenResolution column
select ScreenResolution,
	SUBSTRING_INDEX(ScreenResolution,' ',-1),
    -- 2560x1600
    SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
    -- 2560(width)
	SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1)
    -- 1600 (Height)
from laptopdata;

ALTER TABLE laptopdata
ADD COLUMN ResolutionWidth INTEGER AFTER ScreenResolution,
ADD COLUMN ResolutionHeight INTEGER AFTER ResolutionWidth;

select * from laptopdata;

UPDATE laptopdata
SET ResolutionWidth=SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
	ResolutionHeight=SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1);

select * from laptopdata;

ALTER TABLE laptopdata
ADD COLUMN Touchscreen INTEGER AFTER ResolutionHeight;

UPDATE laptopdata
SET Touchscreen = ScreenResolution LIKE '%Touch%';

SELECT * FROM laptopdata;

ALTER TABLE laptopdata
DROP COLUMN ScreenResolution;

SELECT * FROM laptopdata;

select cpu_name,
	SUBSTRING_INDEX(cpu_name,' ' ,2)
from laptopdata;

update laptopdata
set cpu_name= SUBSTRING_INDEX(cpu_name,' ' ,2);
SELECT distinct cpu_name FROM laptopdata;

-- Cleaning Memory column
ALTER TABLE laptopdata
ADD COLUMN MemoryType varchar(255) after Memory,
ADD COLUMN PrimaryStorage INTEGER after MemoryType,
ADD COLUMN SecondaryStorage INTEGER after PrimaryStorage;

select * from laptopdata;

SELECT Memory,
	CASE 
		WHEN Memory LIKE '%SSD%' and Memory LIKE '%HDD%' THEN 'HYBRID'
		WHEN Memory LIKE '%SSD%' THEN 'SSD'
		WHEN Memory LIKE '%HDD%' THEN 'HDD'
		WHEN Memory LIKE '%Flash Storage%' THEN 'FLASH STORAGE'
		WHEN Memory LIKE '%Hybrid%' THEN 'HYBRID'
		WHEN Memory LIKE '%Flash Storage%' and Memory LIKE '%HDD%' THEN 'HYBRID'
		ELSE NULL
	END AS 'MemoryType'
FROM laptopdata;

update laptopdata
set MemoryType = CASE 
		WHEN Memory LIKE '%SSD%' and Memory LIKE '%HDD%' THEN 'HYBRID'
		WHEN Memory LIKE '%SSD%' THEN 'SSD'
		WHEN Memory LIKE '%HDD%' THEN 'HDD'
		WHEN Memory LIKE '%Flash Storage%' THEN 'FLASH STORAGE'
		WHEN Memory LIKE '%Hybrid%' THEN 'HYBRID'
		WHEN Memory LIKE '%Flash Storage%' and Memory LIKE '%HDD%' THEN 'HYBRID'
		ELSE NULL
	END;
    
select * from laptopdata;

select Memory,
	REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
	CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END
FROM laptopdata;

update laptopdata
SET PrimaryStorage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
	SecondaryStorage =	CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;

select * from laptopdata;

SELECT 
	PrimaryStorage,
	CASE WHEN PrimaryStorage <= 2 THEN PrimaryStorage*1024 ELSE PrimaryStorage END,
	SecondaryStorage,
	CASE WHEN SecondaryStorage <= 2 THEN SecondaryStorage*1024 ELSE SecondaryStorage END
FROM laptopdata;

update laptopdata
SET PrimaryStorage = CASE WHEN PrimaryStorage <= 2 THEN PrimaryStorage*1024 ELSE PrimaryStorage END,
	SecondaryStorage = 	CASE WHEN SecondaryStorage <= 2 THEN SecondaryStorage*1024 ELSE SecondaryStorage END;
select PrimaryStorage from laptopdata
WHERE PrimaryStorage IS NULL;

DELETE FROM laptopdata
WHERE PrimaryStorage IS NULL;

select * from laptopdata;

alter table laptopdata
drop column Memory;
select * from laptopdata;

alter table laptopdata
drop column gpu_name;
select * from laptopdata;




