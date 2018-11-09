-----------------------------------------------------------------------------------------------------------
-- List Databases
-- Configuration: /etc/hive/conf
-----------------------------------------------------------------------------------------------------------
SHOW DATABASES;
-----------------------------------------------------------------------------------------------------------
-- Create Database: Datawarehouse location: /user/hive/warehouse/rc_project_airline.db
-----------------------------------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS rc_project_country;
-----------------------------------------------------------------------------------------------------------
-- Select Database to Use
-----------------------------------------------------------------------------------------------------------
USE rc_project_country;
-----------------------------------------------------------------------------------------------------------
-- CREATING AND LOADING DATA: Airports, Airlines and Routes
-----------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rc_project_country.countryflag 
(name STRING, landmass INT, zone INT, area INT, population INT,
language INT, religion INT, bars INT, stripes INT, colours INT,
red INT, green INT, blue INT, gold INT, white INT, 
black INT, orange INT, mainhue STRING, circles  INT, crosses INT, 
saltires INT, quarters INT, sunstars INT, crescent INT, triangle INT, 
icon INT, animate INT, text INT, topleft STRING, botright STRING) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/projects/country/artifacts/flag.data_dataset.txt' 
OVERWRITE INTO TABLE rc_project_country.countryflag;

-----------------------------------------------------------------------------------------------------------
-- Add JAR and Create Function
-----------------------------------------------------------------------------------------------------------
ADD JAR /mnt/home/edureka_424232/projects/country/jars/bigdata-project.jar;

CREATE TEMPORARY FUNCTION f_landmass AS 'com.practice.bigdata.hadoop.projects.country.LandMass';
CREATE TEMPORARY FUNCTION f_language AS 'com.practice.bigdata.hadoop.projects.country.Language';
CREATE TEMPORARY FUNCTION f_religion AS 'com.practice.bigdata.hadoop.projects.country.Religion';
---------------------------------------------------------------------------------------------------------
-- A. Count number of countries based on landmass.
---------------------------------------------------------------------------------------------------------
-- Show LandaMass and LandMass Country Count
SELECT f_landmass(landmass) AS LandMass, COUNT(*) CountryCount
FROM rc_project_country.countryflag 
GROUP BY landmass;

---------------------------------------------------------------------------------------------------------
-- B. Find out top 5 country with Sum of bars and strips in a flag.
---------------------------------------------------------------------------------------------------------
SELECT countrySum.name, countrySum.total
FROM (SELECT name,  (SUM(bars) + SUM (stripes)) AS total
FROM rc_project_country.countryflag 
GROUP BY  name) AS countrySum
ORDER BY countrySum.total desc
LIMIT 5;

---------------------------------------------------------------------------------------------------------
-- C. Count of countries with icon.
---------------------------------------------------------------------------------------------------------
SELECT COUNT(name)
FROM rc_project_country.countryflag 
WHERE icon=1;
---------------------------------------------------------------------------------------------------------
-- D. Count of countries which have same top left and top right color in flag.
---------------------------------------------------------------------------------------------------------
SELECT COUNT(name)
FROM rc_project_country.countryflag 
WHERE topleft=botright;
---------------------------------------------------------------------------------------------------------
-- E. Count number of countries based on zone.
---------------------------------------------------------------------------------------------------------
SELECT  case 
when zone == 1 then 'NE'
when zone == 2 then 'SE'
when zone == 3 then 'SW'
when zone == 4 then 'NW'
else 'NA'
end as zonediaplay, COUNT(name)
FROM rc_project_country.countryflag 
GROUP BY zone;
---------------------------------------------------------------------------------------------------------
-- F. Find out largest county in terms of area in NE zone.
---------------------------------------------------------------------------------------------------------
SELECT countryNeLargest.name
FROM (SELECT name, area
FROM rc_project_country.countryflag
WHERE zone = 1 --NE
ORDER BY area desc) AS countryNeLargest
limit 1;
---------------------------------------------------------------------------------------------------------
-- G. Find out least populated country in S.America landmass.
---------------------------------------------------------------------------------------------------------
SELECT countryLeast.name
FROM (SELECT name, population
FROM rc_project_country.countryflag
WHERE landmass = 2  --S.America
ORDER BY population) AS countryLeast
limit 1;
---------------------------------------------------------------------------------------------------------
-- H. Find out largest speaking language among all countries.
---------------------------------------------------------------------------------------------------------
SELECT f_language(countryLanguageOrder.language)
FROM
(SELECT language, countryLanguage.count
FROM (SELECT language, COUNT(language) AS count
FROM rc_project_country.countryflag
WHERE language !=10 --Skipping Others
GROUP BY language ) AS countryLanguage
ORDER BY countryLanguage.count desc) AS countryLanguageOrder
limit 1;
---------------------------------------------------------------------------------------------------------
-- I. Find most common colour among flags from all countries.
---------------------------------------------------------------------------------------------------------
SELECT a.colorName,COUNT(a.name) as total
FROM
    (SELECT
       CASE
           WHEN red == 1 then 'Red' 
           WHEN green == 1 then 'Green'
           WHEN blue == 1 then 'Blue'
           WHEN gold == 1 then 'Yellow'
           WHEN white == 1 then 'White'
           WHEN black == 1 then 'Black'
           WHEN orange == 1 then 'Brown'
       end as colorName, name from rc_project_country.countryflag) a
GROUP BY a.colorName
ORDER BY total DESC 
LIMIT 1;
---------------------------------------------------------------------------------------------------------
-- J. Sum of all circles present in all country flags.
---------------------------------------------------------------------------------------------------------
SELECT SUM (circles)
FROM rc_project_country.countryflag;
---------------------------------------------------------------------------------------------------------
-- K. Count of countries which have both icon and text in flag.
---------------------------------------------------------------------------------------------------------
SELECT COUNT (*)
FROM rc_project_country.countryflag
WHERE icon =1 and text=1;

----------------------------------------------------------------------------------------------------------
-- Drop table: 
----------------------------------------------------------------------------------------------------------
DROP TABLE rc_project_country.countryflag;
----------------------------------------------------------------------------------------------------------
-- Drop Database: 
----------------------------------------------------------------------------------------------------------
DROP DATABASE rc_project_country;