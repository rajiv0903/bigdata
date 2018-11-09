-----------------------------------------------------------------------------------------------------------
-- List Databases
-- Configuration: /etc/hive/conf
-----------------------------------------------------------------------------------------------------------
SHOW DATABASES;

-----------------------------------------------------------------------------------------------------------
-- Create Database: Datawarehouse location: /user/hive/warehouse/rc_transaction.db
-----------------------------------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS  rc_transaction;

-----------------------------------------------------------------------------------------------------------
-- Select Database to Use
-----------------------------------------------------------------------------------------------------------
USE rc_transaction;

-----------------------------------------------------------------------------------------------------------
-- Create Table under the Database with Partition and Cluster
-- Data:
-- 100001,6/26/2011,4000001,40.33,Exercise & Fitness,Cardio Machine Accessories,Clarksville,Tennessee,credit
-----------------------------------------------------------------------------------------------------------
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.enforce.bucketing=true;
set mapred.reduce.tasks=10;

CREATE TABLE IF NOT EXISTS  rc_transaction.transaction_records_dynamic_partion_cat (id INT, date STRING, custid INT, amount DOUBLE, product STRING, 
state STRING, pay_mode STRING)
PARTITIONED BY (category STRING)
CLUSTERED BY (state) SORTED BY (state) INTO 10 BUCKETS
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile;

CREATE TABLE IF NOT EXISTS  rc_transaction.transaction_records_static_partion_cat (id INT, date STRING, custid INT, amount DOUBLE, product STRING, 
state STRING, pay_mode STRING)
PARTITIONED BY (category STRING)
CLUSTERED BY (state) SORTED BY (state) INTO 10 BUCKETS
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile;


-----------------------------------------------------------------------------------------------------------
-- LIST TABLES
-----------------------------------------------------------------------------------------------------------
SHOW TABLES;

-----------------------------------------------------------------------------------------------------------
-- Describe
-----------------------------------------------------------------------------------------------------------
DESCRIBE  rc_transaction.transaction_records_dynamic_partion_cat;
DESCRIBE EXTENDED rc_transaction.transaction_records_dynamic_partion_cat; 
DESCRIBE  rc_transaction.transaction_records_static_partion_cat;
DESCRIBE EXTENDED rc_transaction.transaction_records_static_partion_cat;

-----------------------------------------------------------------------------------------------------------
-- Load Data: Dynamic Partition
--Dynamic partition strict mode requires at least one static partition column. To turn this off 
-- set hive.exec.dynamic.partition.mode=nonstrict

-- LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/hive/artifacts/transactions_p_cat1' 
-- INTO TABLE transaction_records_static_partion_cat(category='Air Sports');
-----------------------------------------------------------------------------------------------------------
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.enforce.bucketing=true;
set mapred.reduce.tasks=10;

INSERT OVERWRITE TABLE rc_transaction.transaction_records_dynamic_partion_cat PARTITION(category) 
SELECT id, date , custid, amount, product, state, pay_mode, category from transaction_records; 

-----------------------------------------------------------------------------------------------------------
-- Load Data: Static Partition: No need to select the partition column from source table
-----------------------------------------------------------------------------------------------------------
INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Air Sports') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Air Sports'; 

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Combat Sports') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Combat Sports'; 

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Exercise & Fitness') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Exercise & Fitness'; 

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Games') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Games'; 

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Gymnastics') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Gymnastics'; 

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Indoor Games') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Indoor Games'; 

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Jumping') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Jumping'; 

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Outdoor Play Equipment') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Outdoor Play Equipment'; 

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Outdoor Recreation') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Outdoor Recreation'; 

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Puzzles') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Puzzles';

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Team Sports') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Team Sports';

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Water Sports') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Water Sports';

INSERT INTO TABLE rc_transaction.transaction_records_static_partion_cat PARTITION(category = 'Winter Sports') 
SELECT id, date , custid, amount, product, state, pay_mode from transaction_records
WHERE category='Winter Sports';
----------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------
-- Select table: Partion will be very fast
----------------------------------------------------------------------------------------------------------
SELECT * FROM rc_transaction.transaction_records_dynamic_partion_cat where category = 'Exercise & Fitness';
SELECT * FROM rc_transaction.transaction_records_static_partion_cat where category = 'Exercise & Fitness';
SELECT * FROM rc_transaction.transaction_records where category = 'Exercise & Fitness';

----------------------------------------------------------------------------------------------------------
-- Drop table: 
----------------------------------------------------------------------------------------------------------
DROP table rc_transaction.transaction_records_dynamic_partion_cat;
DROP table rc_transaction.transaction_records_static_partion_cat;

----------------------------------------------------------------------------------------------------------
-- Drop Database: 
----------------------------------------------------------------------------------------------------------
DROP DATABASE rc_transaction;
