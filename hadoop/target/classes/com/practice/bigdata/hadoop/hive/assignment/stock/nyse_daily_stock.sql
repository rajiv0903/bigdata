-----------------------------------------------------------------------------------------------------------
-- List Databases
-- Configuration: /etc/hive/conf
-----------------------------------------------------------------------------------------------------------
SHOW DATABASES;

-----------------------------------------------------------------------------------------------------------
-- Create Database: Datawarehouse location: /user/hive/warehouse/rc_nyse_stock.db
-----------------------------------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS rc_nyse_stock;

-----------------------------------------------------------------------------------------------------------
-- Select Database to Use
-----------------------------------------------------------------------------------------------------------
USE rc_nyse_stock;

-----------------------------------------------------------------------------------------------------------
-- Create Table 
-----------------------------------------------------------------------------------------------------------
CREATE TABLE TABLE IF NOT EXISTS rc_nyse_stock.stock_daily_price
(
exchange_name STRING, 
stock_symbol STRING, 
date_start DATE, 
stock_price_open FLOAT, stock_price_high FLOAT, stock_price_low FLOAT, stock_price_close FLOAT, stock_volume FLOAT, stock_price_adj_close FLOAT 
)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
STORED AS TEXTFILE 
tblproperties ("skip.header.line.count"="1");
-----------------------------------------------------------------------------------------------------------
-- LIST TABLES
-----------------------------------------------------------------------------------------------------------
SHOW TABLES;

-----------------------------------------------------------------------------------------------------------
-- Describe
-----------------------------------------------------------------------------------------------------------
DESCRIBE  rc_nyse_stock.stock_daily_price;
DESCRIBE EXTENDED rc_nyse_stock.stock_daily_price; 

-----------------------------------------------------------------------------------------------------------
-- Load Data
-----------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/hive/artifacts/NYSE_daily_prices_Q.csv' 
OVERWRITE INTO TABLE rc_nyse_stock.stock_daily_price;

-----------------------------------------------------------------------------------------------------------
-- To get the average of the opening price of stocks you use the query below
-----------------------------------------------------------------------------------------------------------
SELECT  a.stock_symbol, count(*),  AVG( stock_price_open) 
FROM  rc_nyse_stock.stock_daily_price a
GROUP BY a.stock_symbol;
-----------------------------------------------------------------------------------------------------------
-- Calculate Covariance
-----------------------------------------------------------------------------------------------------------
set hive.cli.print.header=true;

SELECT a.stock_symbol, b.stock_symbol, year(a.date_start), month(a.date_start),
( AVG(a.stock_price_low * b.stock_price_low) - (AVG(a.stock_price_low) * AVG(b.stock_price_low) )
)
from rc_nyse_stock.stock_daily_price a join rc_nyse_stock.stock_daily_price b on
a.date_start = b.date_start 
WHERE a.stock_symbol < b.stock_symbol 
GROUP BY a.stock_symbol, b.stock_symbol, year(a.date_start), month(a.date_start);


SELECT a.stock_symbol, b.stock_symbol, month(a.date_start),
( AVG(a.stock_price_low * b.stock_price_low) - (AVG(a.stock_price_low) * AVG(b.stock_price_low) )
)
from rc_nyse_stock.stock_daily_price a join rc_nyse_stock.stock_daily_price b on
a.date_start = b.date_start 
WHERE a.stock_symbol < b.stock_symbol 
AND year(a.date_start) = 2008
GROUP BY a.stock_symbol, b.stock_symbol, month(a.date_start); 

SELECT a.stock_symbol AS Stock, b.stock_symbol AS Stock, month(a.date_start) AS Month,
( AVG(a.stock_price_low * b.stock_price_low) - (AVG(a.stock_price_low) * AVG(b.stock_price_low) )
) AS Covariance
from rc_nyse_stock.stock_daily_price a join rc_nyse_stock.stock_daily_price b on
a.date_start = b.date_start 
WHERE a.stock_symbol < b.stock_symbol 
GROUP BY a.stock_symbol, b.stock_symbol, month(a.date_start);
----------------------------------------------------------------------------------------------------------
-- Select table: 
----------------------------------------------------------------------------------------------------------
SELECT * FROM rc_nyse_stock.stock_daily_price;
SELECT a.*, month(a.date_start), year(a.date_start)  FROM rc_nyse_stock.stock_daily_price a limit 10;
----------------------------------------------------------------------------------------------------------
-- Drop table: 
----------------------------------------------------------------------------------------------------------
DROP table rc_nyse_stock.stock_daily_price;

----------------------------------------------------------------------------------------------------------
-- Drop Database: 
----------------------------------------------------------------------------------------------------------
DROP DATABASE rc_nyse_stock;