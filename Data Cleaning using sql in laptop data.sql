SELECT * FROM eda.laptops;
USE eda;

 # Changing column name Unamed:0 to index
ALTER TABLE laptops RENAME COLUMN `Unnamed: 0` to `index`;

# Creating Backup before doing Data Cleaning
Create table laptop_bkp like laptops;
# inserting values from laptops table
insert into laptop_bkp
select * from laptops;

# Checking no of rows
select count(*) from laptops;
#total 1272 rows present in our dataset

#Checking memory consumption for reference
SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'EDA'
AND TABLE_NAME = 'laptops';
#--> Memory consumption is 256.00

#DROP NULL values
select  * from laptops
where Company IS NULL AND TypeName IS NULL AND Inches IS NULL AND ScreenResolution IS NULL AND Cpu IS NULL
AND Ram IS NULL AND Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND Weight IS NULL AND Price IS NULL;

#No null values present in the dataset

#Drop duplicates
#Checking for duplicate values
select Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu,OpSys,Weight,Price,count(*) from laptops
group by Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu,OpSys,Weight,Price
HAVING count(*)>1;

#Dropping duplicates
DELETE FROM laptops 
WHERE `index` NOT IN (
    SELECT * FROM (
        SELECT MIN(`index`) 
        FROM laptops
        GROUP BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price
    ) AS subquery
);

# Changing the Imches column type to Decimal from Double
ALTER TABLE laptops MODIFY COLUMN Inches Decimal(10,1);

# Removing the Ram columns GB part so that we can convert the type of the column from text to integer
UPDATE laptops l1
INNER JOIN (
    SELECT `index`, REPLACE(Ram, 'GB', '') AS new_Ram
    FROM laptops
) AS derived_table
ON l1.`index` = derived_table.`index`
SET l1.Ram = derived_table.new_Ram;

select * from laptops;
# Now changing the column datatype to integer from text
ALTER TABLE laptops MODIFY COLUMN Ram INTEGER;

# Removing the Weight column's kg part so that we can convert the type of the column from text to integer
update laptops l1
join (select `index`,REPLACE(Weight,'kg','') weight from laptops) l2
on l1.`index`=l2.`index`
set l1.Weight=l2.weight;

update laptops l1
join (select `index`,ROUND(Weight) weight from laptops) l2
on l1.`index`=l2.`index`
set l1.Weight=l2.weight;

SELECT *
FROM laptops
WHERE Weight = '0';
# Now changing the column datatype to integer from text
ALTER TABLE laptops MODIFY COLUMN Weight INTEGER;

# Price column is in double type , rounding the value of price column and changing the data type
UPDATE laptops l1
join (select `index`, round(Price) price from laptops)l2
on l1.`index`=l2.`index`
SET l1.Price=l2.price;

#Now changing the data type to integer from double
ALTER TABLE laptops MODIFY Price INTEGER;
SELECT * FROM laptops;

# Dividing all the rows in three category macOS,Windows,Linux for OpSys
select `index`,OpSys,
CASE
  WHEN OpSys LIKE "%mac%" THEN 'MacOS'
  WHEN OpSys LIKE "%windows%" THEN 'Windows'
  WHEN OpSys LIKE "%linux%" THEN 'Linux'
  WHEN OpSys LIKE "%NO OS" THEN 'N/A'
  ELSE 'Other'
END as 'Os_brand'
From laptops;

#Updating the values
UPDATE laptops l1
join (select `index`,OpSys,
CASE
  WHEN OpSys LIKE "%mac%" THEN 'MacOS'
  WHEN OpSys LIKE "%windows%" THEN 'Windows'
  WHEN OpSys LIKE "%linux%" THEN 'Linux'
  WHEN OpSys LIKE "%NO OS" THEN 'N/A'
  ELSE 'Other'
END as 'Os_brand'
From laptops)l2
on l1.`index`=l2.`index`
set l1.OpSys=l2.Os_brand;

select * from laptops;
 #Creating two diffrent column from gpu_brand,gpu_name
 ALTER TABLE laptops ADD COLUMN gpu_brand VARCHAR(255) AFTER gpu;
 ALTER TABLE laptops ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;
 
 # Filtering data for update splitting gpu_brand and gpu_name from gpu
 UPDATE laptops l1
 join (select `index`, SUBSTRING_INDEX (Gpu,' ',1) gpu_brand from laptops)l2
 on l1.`index`=l2.`index`
 set l1.gpu_brand=l2.gpu_brand;
 
 
 UPDATE laptops l1
 join (select `index`,REPLACE(Gpu,gpu_brand,' ') gpu_name from laptops)l2
 on l1.`index`=l2.`index`
 set l1.gpu_name=l2.gpu_name;
 
 ALTER TABLE laptops drop column Gpu;
 select * from laptops;
#Creating three diffrent column from Cpu , cpu_brand,cpu_speed,cpu_name
 ALTER TABLE laptops ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu;
 ALTER TABLE laptops ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand;
 ALTER TABLE laptops ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;
 
 #Updating cpu_speed
 update laptops l1
 join (select `index`, REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz','') cpu_speed from laptops)l2
 on l1.`index`=l2.`index`
 set l1.cpu_speed=l2.cpu_speed;
 #updating cpu_brand
 update laptops l1
 join (select `index`, SUBSTRING_INDEX(Cpu,' ',1) cpu_brand from laptops)l2
 on l1.`index`=l2.`index`
 set l1.cpu_brand=l2.cpu_brand;
 #updating cpu_name
 update laptops l1
 join (select `index`, replace(REPLACE(Cpu,cpu_brand,''),substring_index(Cpu,' ',-1),'') cpu_name from laptops) l2
 on l1.`index`=l2.`index`
 set l1.cpu_name=l2.cpu_name;
 
 #dropping Cpu column
 Alter table laptops drop column Cpu;
 
 #Now Lets analyze screenresolution to extract resolution_width and resolution_height
SELECT ScreenResolution,
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1)
FROM laptops;
#creating two columns resolution_width and resolution_height
ALTER TABLE laptops
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;
ALTER TABLE laptops
ADD COLUMN Touchscreen INTEGER AFTER resolution_height;

SELECT * FROM laptops;
#Updating ScreenResolution,resolution_width
update laptops l1
join(select `index`, SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1) width FROM laptops)l2
on l1.`index`=l2.`index`
set l1.resolution_width=l2.width;

update laptops l1
join(select `index`, SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1) height FROM laptops)l2
on l1.`index`=l2.`index`
set l1.resolution_height=l2.height;

update laptops l1
join (select `index`,
case
  when ScreenResolution LIKE '%touch%' THEN 1
  ELSE 0
END as Touchscreen
FROM laptops)l2
on l1.`index`=l2.`index`
set l1.Touchscreen=l2.Touchscreen;

#Dropping the ScreenResolution column
ALTER TABLE laptops
drop column ScreenResolution;




#Splitting the Memory value and creating two coloumns primary_storage,secondary_storage and Memory_type 
#Memory column
SELECT Memory FROM laptops;


ALTER TABLE laptops
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;
SELECT Memory,
CASE
WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
WHEN Memory LIKE '%SSD%' THEN 'SSD'
WHEN Memory LIKE '%HDD%' THEN 'HDD'
WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
ELSE NULL
END AS 'memory_type'
FROM laptops;
UPDATE laptops
SET memory_type = CASE
WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
WHEN Memory LIKE '%SSD%' THEN 'SSD'
WHEN Memory LIKE '%HDD%' THEN 'HDD'
WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
ELSE NULL
END;
SELECT Memory,
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
CASE WHEN Memory LIKE '%+%' THEN
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END
FROM laptops;
UPDATE laptops
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;
SELECT
primary_storage,
CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage,
CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE
secondary_storage END
FROM laptops;
UPDATE laptops
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE
primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024
ELSE secondary_storage END;
SELECT * FROM laptops;
ALTER TABLE laptops DROP COLUMN Memory;
SELECT * FROM laptops;
  
  
  













# Changing Ram columns data type to int



