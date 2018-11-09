-----------------------------------------------------------------------------------------------------------
-- List Databases
-- Configuration: /etc/hive/conf
-----------------------------------------------------------------------------------------------------------
SHOW DATABASES;
-----------------------------------------------------------------------------------------------------------
-- Create Database: Datawarehouse location: /user/hive/warehouse/rc_project_airline.db
-----------------------------------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS rc_project_airline;
-----------------------------------------------------------------------------------------------------------
-- Select Database to Use
-----------------------------------------------------------------------------------------------------------
USE rc_project_airline;
-----------------------------------------------------------------------------------------------------------
-- CREATING AND LOADING DATA: Airports, Airlines and Routes
-----------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rc_project_airline.airports 
(airport_id STRING, name STRING, city STRING, country STRING, 
IATA_FAA STRING, ICAO STRING, latitude STRING, longitude STRING,
altitude STRING, TimeZone STRING, DST STRING, TZ STRING ) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/projects/airline/artifacts/airports_mod.dat' 
OVERWRITE INTO TABLE rc_project_airline.airports;

CREATE TABLE IF NOT EXISTS rc_project_airline.finalairlines 
(airline STRING, name STRING, alias STRING, IATA STRING, 
ICAO STRING, callsign STRING, country STRING, active STRING ) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/projects/airline/artifacts/Final_airlines' 
OVERWRITE INTO TABLE rc_project_airline.finalairlines;


CREATE TABLE IF NOT EXISTS rc_project_airline.routes 
(airlines STRING, airline_id STRING, source_airport STRING, source_airport_id STRING, 
destination_airport STRING, destination_airport_id STRING, code_share STRING, stops STRING, 
eqipments STRING) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/projects/airline/artifacts/routes.dat' 
OVERWRITE INTO TABLE rc_project_airline.routes;

---------------------------------------------------------------------------------------------------------
-- A: Find list of Airports operating in the Country India
----------------------------------------------------------------------------------------------------------
select * from rc_project_airline.airports a  where lower(a.country) = 'india';
---------------------------------------------------------------------------------------------------------
-- B: Find the list of Airlines having zero stops
----------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rc_project_airline.zerostopsairlineroutes 
(airline_id STRING) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE rc_project_airline.zerostopsairlineroutes
SELECT b.airline_id, SUM(b.stops)
FROM
    rc_project_airline.routes b
GROUP BY b.airline_id
HAVING
    SUM(b.stops) > 0;
    
SELECT a.*
FROM rc_project_airline.finalairlines  a 
JOIN  rc_project_airline.zerostopsairlineroutes b 
ON a.airline = b.airline_id;


---------------------------------------------------------------------------------------------------------
-- C: List of Airlines operating with code share
----------------------------------------------------------------------------------------------------------

SELECT a.*
FROM rc_project_airline.finalairlines  a 
JOIN (SELECT DISTINCT(r.airline_id) 
FROM rc_project_airline.routes  r 
WHERE r.code_share ='Y') AS code_share
ON a.airline = code_share.airline_id
ORDER BY CAST(a.airline AS INT);

---------------------------------------------------------------------------------------------------------
-- D: Which country (or) territory having highest Airports
----------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS rc_project_airline.country_airline 
(country STRING, airport_count INT) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE rc_project_airline.country_airline
SELECT airport_grouping.country, airport_grouping.total_airport
FROM 
(SELECT a.country, COUNT(a.airport_id) AS total_airport
FROM rc_project_airline.airports a
GROUP BY a.country ) AS airport_grouping
ORDER BY airport_grouping.total_airport desc;

SELECT ca.country
FROM rc_project_airline.country_airline ca
LIMIT 1;
---------------------------------------------------------------------------------------------------------
-- E: Find the list of Active Airlines in United state
-- Relying on Routes Table
----------------------------------------------------------------------------------------------------------

SELECT a.*
FROM rc_project_airline.finalairlines a
JOIN (SELECT DISTINCT(r.airline_id) 
FROM rc_project_airline.routes  r) AS active_airline_route
ON a.airline = active_airline_route.airline_id
WHERE lower(a.country) = 'united states';
----------------------------------------------------------------------------------------------------------
-- Drop table: 
----------------------------------------------------------------------------------------------------------
DROP TABLE rc_project_airline.airports;
DROP TABLE rc_project_airline.finalairlines;
DROP TABLE rc_project_airline.routes;
DROP TABLE rc_project_airline.zerostopsairlineroutes;
DROP TABLE rc_project_airline.country_airline;
----------------------------------------------------------------------------------------------------------
-- Drop Database: 
----------------------------------------------------------------------------------------------------------
DROP DATABASE rc_project_airline;