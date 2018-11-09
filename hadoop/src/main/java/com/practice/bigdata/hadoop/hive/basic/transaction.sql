-----------------------------------------------------------------------------------------------------------
-- List Databases
-- Configuration: /etc/hive/conf
-----------------------------------------------------------------------------------------------------------
SHOW DATABASES;

-----------------------------------------------------------------------------------------------------------
-- Create Database: Datawarehouse location: /user/hive/warehouse/rc_transaction.db
-----------------------------------------------------------------------------------------------------------
CREATE DATABASE rc_transaction;

-----------------------------------------------------------------------------------------------------------
-- Select Database to Use
-----------------------------------------------------------------------------------------------------------
USE rc_transaction;

-----------------------------------------------------------------------------------------------------------
-- Create Table under the Database
-- Data:
-- 100001,6/26/2011,4000001,40.33,Exercise & Fitness,Cardio Machine Accessories,Clarksville,Tennessee,credit
-----------------------------------------------------------------------------------------------------------
CREATE TABLE transaction_records (id INT, date STRING, custid INT, amount DOUBLE, 
category STRING, product STRING, state STRING, pay_mode STRING)
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile;

-----------------------------------------------------------------------------------------------------------
-- LIST TABLES
-----------------------------------------------------------------------------------------------------------
SHOW TABLES;

-----------------------------------------------------------------------------------------------------------
-- Alter Table Add Column
-----------------------------------------------------------------------------------------------------------
ALTER TABLE transaction_records ADD columns (country STRING);

-----------------------------------------------------------------------------------------------------------
-- Describe
-----------------------------------------------------------------------------------------------------------
DESCRIBE  transaction_records;
DESCRIBE EXTENDED transaction_records;

-----------------------------------------------------------------------------------------------------------
-- Drop Column: We cannot drop column by column name; we can replace the the schema
-- country wanted to drop hence new structure
-----------------------------------------------------------------------------------------------------------
ALTER TABLE transaction_records REPLACE COLUMNS(id INT, date STRING, custid INT, amount DOUBLE, 
category STRING, product STRING, state STRING, 
pay_mode STRING);

DESCRIBE transaction_records;

-----------------------------------------------------------------------------------------------------------
-- Load Data:
-- LOAD LOCAL: Loading Data from Local File System to Hive Location- File Copy
-- LOAD: Loading Data from HDFS Location to Hive Location- File Move (File will no longer exist at HDFS)
-- OVERWRITE: If we do not use OVERWRITE then a new file will get created
--			Under /user/hive/warehouse/rc_transaction.db/transaction_records
--				  hdfs://nameservice1/apps/hive/warehouse/rc_transaction.db/transaction_records
-----------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/hive/artifacts/transactions' 
OVERWRITE INTO TABLE transaction_records;

LOAD DATA INPATH 'hive_filesystem/transaction/input/transactions' 
OVERWRITE INTO TABLE transaction_records;

ALTER TABLE transaction_records ADD columns (country STRING);
-- Country will be NULL
SELECT * FROM transaction_records LIMIT 10;
-- Drop Column
ALTER TABLE  transaction_records DROP country;
-- Revert back to original schema
ALTER TABLE transaction_records REPLACE COLUMNS(id INT, date STRING, custid INT, amount DOUBLE, 
category STRING, product STRING, state STRING, 
pay_mode STRING);

----------------------------------------------------------------------------------------------------------
-- Drop table: 
----------------------------------------------------------------------------------------------------------
DROP table transaction_records;

----------------------------------------------------------------------------------------------------------
-- Drop Database: 
----------------------------------------------------------------------------------------------------------
DROP DATABASE rc_transaction;