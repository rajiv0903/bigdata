-----------------------------------------------------------------------------------------------------------
-- List Databases
-- Configuration: /etc/hive/conf
-----------------------------------------------------------------------------------------------------------
SHOW DATABASES;
-----------------------------------------------------------------------------------------------------------
-- Create Database: Datawarehouse location: /user/hive/warehouse/rc_project_youtube.db
-----------------------------------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS rc_project_youtube;
-----------------------------------------------------------------------------------------------------------
-- Select Database to Use
-----------------------------------------------------------------------------------------------------------
USE rc_project_youtube;
-----------------------------------------------------------------------------------------------------------
-- CREATING AND LOADING DATA: BOOKS
-----------------------------------------------------------------------------------------------------------
-- Related Video ID Not required for Analysis
CREATE TABLE IF NOT EXISTS rc_project_youtube.videos 
(id STRING, uploader STRING, interval INT, category STRING, 
length INT, views INT, rating double, ratingcount INT,
comments INT) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/projects/youtube/artifacts/youtubedata.txt.txt' 
OVERWRITE INTO TABLE rc_project_youtube.videos;

---------------------------------------------------------------------------------------------------------
-- A: Find out the top 5 categories with maximum number of videos uploaded.
----------------------------------------------------------------------------------------------------------
SELECT v.category, count(v.category) AS totalupload
FROM rc_project_youtube.videos v
GROUP BY v.category
ORDER BY totalupload desc
limit 5;
---------------------------------------------------------------------------------------------------------
-- B: Find out the top 10 rated videos.
----------------------------------------------------------------------------------------------------------
SELECT v.id, v.ratingcount
FROM rc_project_youtube.videos v
ORDER BY v.ratingcount desc
limit 10;
---------------------------------------------------------------------------------------------------------
-- C: Find out the most viewed videos.
----------------------------------------------------------------------------------------------------------
SELECT v.id, v.views
FROM rc_project_youtube.videos v
ORDER BY v.views desc
limit 1;
----------------------------------------------------------------------------------------------------------
-- Drop table: 
----------------------------------------------------------------------------------------------------------
DROP TABLE rc_project_youtube.videos;
----------------------------------------------------------------------------------------------------------
-- Drop Database: 
----------------------------------------------------------------------------------------------------------
DROP DATABASE rc_project_youtube;