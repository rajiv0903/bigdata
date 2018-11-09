
--
--Run Command:
-- hive --hiveconf table_data_path=/mnt/home/edureka_424232/hive/artifacts/NYSE_daily_prices_Q.csv -f /mnt/home/edureka_424232/hive/scripts/stock_covariance.sql

CREATE DATABASE IF NOT EXISTS rc_nyse_stock;

CREATE TABLE IF NOT EXISTS rc_nyse_stock.stock_daily_price
(
exchange_name STRING, 
stock_symbol STRING, 
date_start DATE, 
stock_price_open FLOAT, 
stock_price_high FLOAT, 
stock_price_low FLOAT, 
stock_price_close FLOAT, stock_volume FLOAT, stock_price_adj_close FLOAT 
)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
STORED AS TEXTFILE 
tblproperties ("skip.header.line.count"="1");

DESCRIBE  rc_nyse_stock.stock_daily_price;

--/mnt/home/edureka_424232/hive/artifacts/NYSE_daily_prices_Q.csv
LOAD DATA LOCAL INPATH '${hiveconf:table_data_path}' 
OVERWRITE INTO TABLE rc_nyse_stock.stock_daily_price;

set hive.cli.print.header=true;

SELECT a.stock_symbol AS Stock, b.stock_symbol AS Stock, month(a.date_start) AS Month,
( AVG(a.stock_price_low * b.stock_price_low) - (AVG(a.stock_price_low) * AVG(b.stock_price_low) )
) AS Covariance
from rc_nyse_stock.stock_daily_price a join rc_nyse_stock.stock_daily_price b on
a.date_start = b.date_start 
WHERE a.stock_symbol < b.stock_symbol 
GROUP BY a.stock_symbol, b.stock_symbol, month(a.date_start);