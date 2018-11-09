-----------------------------------------------------------------------------------------------------------
-- List Databases
-- Configuration: /etc/hive/conf
-----------------------------------------------------------------------------------------------------------
SHOW DATABASES;

-----------------------------------------------------------------------------------------------------------
-- Create Database: Datawarehouse location: /user/hive/warehouse/rc_user_movie_mapreduce.db
-----------------------------------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS rc_user_movie_mapreduce;

-----------------------------------------------------------------------------------------------------------
-- Select Database to Use
-----------------------------------------------------------------------------------------------------------
USE rc_user_movie_mapreduce;

-----------------------------------------------------------------------------------------------------------
-- Create Table 
-----------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rc_user_movie_mapreduce.user_movie_watch (userid INT, movieid INT, rating INT, unixtime STRING)
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile;

CREATE TABLE IF NOT EXISTS rc_user_movie_mapreduce.user_movie_watch_weekday (userid INT, movieid INT, rating INT, weekday INT)
row format delimited
fields terminated by '\t';

-----------------------------------------------------------------------------------------------------------
-- LIST TABLES
-----------------------------------------------------------------------------------------------------------
SHOW TABLES;

-----------------------------------------------------------------------------------------------------------
-- Describe
-----------------------------------------------------------------------------------------------------------
DESCRIBE  rc_user_movie_mapreduce.user_movie_watch;
DESCRIBE EXTENDED rc_user_movie_mapreduce.user_movie_watch; 

DESCRIBE  rc_user_movie_mapreduce.user_movie_watch_weekday;
DESCRIBE EXTENDED rc_user_movie_mapreduce.user_movie_watch_weekday; 

-----------------------------------------------------------------------------------------------------------
-- Load Data
-----------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/hive/artifacts/user_movie_watch' 
OVERWRITE INTO TABLE rc_user_movie_mapreduce.user_movie_watch;

-----------------------------------------------------------------------------------------------------------
-- Add Python File
-----------------------------------------------------------------------------------------------------------
ADD FILE /mnt/home/edureka_424232/hive/artifacts/weekday_mapper.py;

-----------------------------------------------------------------------------------------------------------
-- Load Data into user_movie_watch_weekday using python
-----------------------------------------------------------------------------------------------------------
INSERT OVERWRITE TABLE rc_user_movie_mapreduce.user_movie_watch_weekday
SELECT TRANSFORM (userid , movieid , rating , unixtime )
USING 'python weekday_mapper.py' AS (userid , movieid , rating , weekday )
FROM rc_user_movie_mapreduce.user_movie_watch;

----------------------------------------------------------------------------------------------------------
-- Select table: 
----------------------------------------------------------------------------------------------------------
SELECT * FROM rc_user_movie_mapreduce.user_movie_watch;
SELECT * FROM rc_user_movie_mapreduce.user_movie_watch_weekday;

----------------------------------------------------------------------------------------------------------
-- Drop table: 
----------------------------------------------------------------------------------------------------------
DROP table rc_user_movie_mapreduce.user_movie_watch;
DROP table rc_user_movie_mapreduce.user_movie_watch_weekday;

----------------------------------------------------------------------------------------------------------
-- Drop Database: 
----------------------------------------------------------------------------------------------------------
DROP DATABASE rc_user_movie_mapreduce;