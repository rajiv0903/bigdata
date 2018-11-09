-----------------------------------------------------------------------------------------------------------
-- List Databases
-- Configuration: /etc/hive/conf
-----------------------------------------------------------------------------------------------------------
SHOW DATABASES;
-----------------------------------------------------------------------------------------------------------
-- Create Database: Datawarehouse location: /user/hive/warehouse/rc_project_book.db
-----------------------------------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS rc_project_book;
-----------------------------------------------------------------------------------------------------------
-- Select Database to Use
-----------------------------------------------------------------------------------------------------------
USE rc_project_book;
-----------------------------------------------------------------------------------------------------------
-- CREATING AND LOADING DATA: BOOKS
-----------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rc_project_book.books 
(ISBN STRING, Title STRING, Author STRING, Year_of_Pub STRING, 
Publisher STRING, Image_URL_S STRING, Image_URL_M STRING, Image_URL_L STRING ) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\;'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE 
tblproperties ("skip.header.line.count"="1");

LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/projects/book/artifacts/BX-Books-Converted.csv' 
OVERWRITE INTO TABLE rc_project_book.books;

---------------------------------------------------------------------------------------------------------
-- A: Find out the frequency of books published each year.
----------------------------------------------------------------------------------------------------------
SELECT Year_of_Pub, count(DISTINCT Title) as Count_of_Pubs 
FROM rc_project_book.books 
group by Year_of_Pub sort by Count_of_Pubs DESC;

---------------------------------------------------------------------------------------------------------
-- B: Find out in which year maximum number of books were published
----------------------------------------------------------------------------------------------------------
SELECT Year_of_Pub, count(DISTINCT Title) as Count_of_Pubs 
FROM rc_project_book.books 
GROUP by Year_of_Pub 
SORT BY Count_of_Pubs DESC limit 1;

---------------------------------------------------------------------------------------------------------
-- C: Find out how many book were published based on ranking in the year 2002.
----------------------------------------------------------------------------------------------------------
-- Step 1: CREATING AND LOADING DATA: BOOK-RATINGS
-- Step 2: JOINING BOTH THE TABLES - BOOKS AND BOOK_RATING_INT
----------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rc_project_book.book_rating
(USER_ID STRING, ISBN STRING, Rating STRING) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY "\;" 
LINES TERMINATED BY '\n'
STORED AS TEXTFILE 
tblproperties ("skip.header.line.count"="1");

LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/projects/book/artifacts/BX-Book-Ratings.csv' 
OVERWRITE INTO TABLE rc_project_book.book_rating;

-- CREATING AND OVERWRITNG TABLE: BOOK_RATING_INT: 
-- CONVERTING RATING AND USER_ID AS INTEGERS FROM STRING DATA TYPE
CREATE TABLE IF NOT EXISTS rc_project_book.book_rating_int 
(USER_ID INT, ISBN STRING, Rating INT) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY "," 
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE rc_project_book.book_rating_int
SELECT 
regexp_replace(USER_ID,"\"",""), 
ISBN,
regexp_replace(Rating,"\"","") 
FROM rc_project_book.book_rating;

--JOINING BOTH THE TABLES - BOOKS AND BOOK_RATING_INT
CREATE TABLE IF NOT EXISTS rc_project_book.book_join 
(ISBN STRING, Year_of_Pub INT, Title STRING, Rating INT) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ","
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE rc_project_book.book_join
SELECT a.ISBN, regexp_replace(a.Year_of_Pub,"\"",""), a.Title, b.Rating
FROM rc_project_book.books a 
JOIN rc_project_book.book_rating_int b 
ON a.ISBN = b.ISBN;

SELECT Rating, count(Title) from book_join where Year_of_Pub = 2002 
group by Rating order by Rating asc;
----------------------------------------------------------------------------------------------------------
-- Drop table: 
----------------------------------------------------------------------------------------------------------
DROP TABLE rc_project_book.books;
DROP TABLE rc_project_book.book_rating;
DROP TABLE rc_project_book.book_rating_int;
DROP TABLE rc_project_book.book_join;

----------------------------------------------------------------------------------------------------------
-- Drop Database: 
----------------------------------------------------------------------------------------------------------
DROP DATABASE rc_project_book;