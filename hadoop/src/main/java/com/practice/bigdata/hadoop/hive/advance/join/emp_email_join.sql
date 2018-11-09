-----------------------------------------------------------------------------------------------------------
-- List Databases
-- Configuration: /etc/hive/conf
-----------------------------------------------------------------------------------------------------------
SHOW DATABASES;

-----------------------------------------------------------------------------------------------------------
-- Create Database: Datawarehouse location: /user/hive/warehouse/rc_employee_join.db
-----------------------------------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS rc_employee_join;

-----------------------------------------------------------------------------------------------------------
-- Select Database to Use
-----------------------------------------------------------------------------------------------------------
USE rc_employee_join;

-----------------------------------------------------------------------------------------------------------
-- Create Table 
-----------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rc_employee_join.employee (name STRING, salary FLOAT, city STRING)
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile;

CREATE TABLE rc_employee_join.employee_email (name STRING, email STRING)
row format delimited
fields terminated by ',';

-----------------------------------------------------------------------------------------------------------
-- LIST TABLES
-----------------------------------------------------------------------------------------------------------
SHOW TABLES;

-----------------------------------------------------------------------------------------------------------
-- Describe
-----------------------------------------------------------------------------------------------------------
DESCRIBE  rc_employee_join.employee;
DESCRIBE EXTENDED rc_employee_join.employee; 

DESCRIBE  rc_employee_join.employee_email;
DESCRIBE EXTENDED rc_employee_join.employee_email; 

-----------------------------------------------------------------------------------------------------------
-- Load Data
-----------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/hive/artifacts/emp_join' 
OVERWRITE INTO TABLE rc_employee_join.employee;

LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/hive/artifacts/emp_email_join' 
OVERWRITE INTO TABLE rc_employee_join.employee_email;

-----------------------------------------------------------------------------------------------------------
-- Join Queries
-----------------------------------------------------------------------------------------------------------
--Equi Join
SELECT emp.*, empmail.email FROM rc_employee_join.employee emp JOIN 
rc_employee_join.employee_email empmail ON emp.name= empmail.name;

--Left Outer Join
SELECT emp.*, empmail.email FROM rc_employee_join.employee emp LEFT OUTER JOIN 
rc_employee_join.employee_email empmail 
ON emp.name= empmail.name;

--Right Outer Join
SELECT emp.*, empmail.email FROM rc_employee_join.employee emp RIGHT OUTER JOIN 
rc_employee_join.employee_email empmail 
ON emp.name= empmail.name;

--Full Outer Join
SELECT emp.*, empmail.email FROM rc_employee_join.employee emp FULL OUTER JOIN 
rc_employee_join.employee_email empmail 
ON emp.name= empmail.name;

----------------------------------------------------------------------------------------------------------
-- Drop table: 
----------------------------------------------------------------------------------------------------------
DROP table employee;
DROP table employee_email;

----------------------------------------------------------------------------------------------------------
-- Drop Database: 
----------------------------------------------------------------------------------------------------------
DROP DATABASE rc_employee_join;