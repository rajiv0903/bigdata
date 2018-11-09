-----------------------------------------------------------------------------------------------------------
-- List Databases
-- Configuration: /etc/hive/conf
-----------------------------------------------------------------------------------------------------------
SHOW DATABASES;

-----------------------------------------------------------------------------------------------------------
-- Create Database: Datawarehouse location: /user/hive/warehouse/rc_employee_join.db
-----------------------------------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS rc_employee_stackoverflow;

-----------------------------------------------------------------------------------------------------------
-- Select Database to Use
-----------------------------------------------------------------------------------------------------------
USE rc_employee_stackoverflow;

-----------------------------------------------------------------------------------------------------------
-- Create Table 
-----------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rc_employee_stackoverflow.comments 
(id INT, user_id INT)
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile;

CREATE TABLE IF NOT EXISTS rc_employee_stackoverflow.posts
(id INT, post_type INT, creation_date STRING, score INT, 
viewcount INT, owneruserid INT, title STRING, answercount INT, commentcount INT)
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile;

CREATE TABLE IF NOT EXISTS rc_employee_stackoverflow.posttypes 
(id INT, name STRING)
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile;

CREATE TABLE IF NOT EXISTS rc_employee_stackoverflow.users 
(id INT, reputation INT, displayname STRING, loc STRING, age INT)
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
DESCRIBE  rc_employee_stackoverflow.comments;
DESCRIBE  rc_employee_stackoverflow.posts;
DESCRIBE  rc_employee_stackoverflow.posttypes;
DESCRIBE  rc_employee_stackoverflow.users;
-----------------------------------------------------------------------------------------------------------
-- Load Data
-----------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/projects/stackoverflow/artifacts/comments.csv'
OVERWRITE INTO TABLE rc_employee_stackoverflow.comments;

LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/projects/stackoverflow/artifacts/posts.csv' 
OVERWRITE INTO TABLE rc_employee_stackoverflow.posts;

LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/projects/stackoverflow/artifacts/posttypes.csv' 
OVERWRITE INTO TABLE rc_employee_stackoverflow.posttypes;

LOAD DATA LOCAL INPATH '/mnt/home/edureka_424232/projects/stackoverflow/artifacts/users.csv' 
OVERWRITE INTO TABLE rc_employee_stackoverflow.users;

-----------------------------------------------------------------------------------------------------------
-- A- Find the display name and no. of posts created by the user who has got maximum reputation.
-----------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS rc_employee_stackoverflow.usermaxrepuration 
(id INT, reputation INT, displayname STRING) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE rc_employee_stackoverflow.usermaxrepuration
SELECT u.id, u.reputation, u.displayname
FROM rc_employee_stackoverflow.users u
ORDER BY u.reputation desc
LIMIT 1;

SELECT umax.displayname, COUNT(p.id)
FROM rc_employee_stackoverflow.posts p
JOIN rc_employee_stackoverflow.usermaxrepuration umax ON p.owneruserid = umax.id
GROUP BY umax.displayname;
-----------------------------------------------------------------------------------------------------------
-- B- Find the average age of users on the Stack Overflow site.
-----------------------------------------------------------------------------------------------------------
SELECT AVG(u.age) 
FROM rc_employee_stackoverflow.users u;

-----------------------------------------------------------------------------------------------------------
-- C- Find the display name of user who posted the oldest post on Stack Overflow (in terms of date).
-----------------------------------------------------------------------------------------------------------
SELECT u.displayname
FROM rc_employee_stackoverflow.users u
JOIN (SELECT p.owneruserid, FROM_UNIXTIME(UNIX_TIMESTAMP(p.creation_date, 'yyyy-MM-dd HH:mm:ss')) AS postDateTimeStamp 
FROM rc_employee_stackoverflow.posts p
WHERE LENGTH(NVL(p.creation_date,0))> 0
ORDER BY postDateTimeStamp 
LIMIT 1) oldestPost ON oldestPost.owneruserid = u.id;


-----------------------------------------------------------------------------------------------------------
-- D- Find the display name and no. of comments done by the user who has got maximum reputation.
-----------------------------------------------------------------------------------------------------------
SELECT u.displayname
FROM rc_employee_stackoverflow.users u
JOIN (SELECT c.user_id , COUNT(c.id) AS commentsCount
FROM rc_employee_stackoverflow.comments c
GROUP BY c.user_id
ORDER BY commentsCount DESC
LIMIT 1 ) maxComments ON maxComments.user_id = u.id;

-----------------------------------------------------------------------------------------------------------
-- E- Find the display name of user who has created maximum no. of posts on Stack Overflow.
--	Find the display name of user who has commented maximum no. of posts on Stack Overflow.
-----------------------------------------------------------------------------------------------------------
--Find the display name of user who has created maximum no. of posts on Stack Overflow.

SELECT u.displayname
FROM rc_employee_stackoverflow.users u
JOIN (SELECT p.owneruserid , COUNT(p.id) AS postCount
FROM rc_employee_stackoverflow.posts p
WHERE LENGTH(NVL(p.title,0))> 0 AND p.post_type =1 
GROUP BY p.owneruserid
ORDER BY postCount DESC
LIMIT 1 ) maxCreatedPost ON maxCreatedPost.owneruserid = u.id;


--Find the display name of user who has commented maximum no. of posts on Stack Overflow.

SELECT u.displayname
FROM rc_employee_stackoverflow.users u
JOIN (SELECT c.user_id , COUNT(c.id) AS commentsCount
FROM rc_employee_stackoverflow.comments c
GROUP BY c.user_id
ORDER BY commentsCount DESC
LIMIT 1 ) maxComments ON maxComments.user_id = u.id;


-----------------------------------------------------------------------------------------------------------
-- F- Find the owner name and id of user whose post has got maximum no. of view counts so far.
-----------------------------------------------------------------------------------------------------------

SELECT u.id, u.displayname
FROM rc_employee_stackoverflow.users u
JOIN (SELECT p.owneruserid , p.viewcount
FROM rc_employee_stackoverflow.posts p
WHERE LENGTH(NVL(p.title,0))> 0
ORDER BY p.viewcount DESC
LIMIT 1 ) maxViewsPost ON maxViewsPost.owneruserid = u.id;

-----------------------------------------------------------------------------------------------------------
-- G- Find the title and owner name of the post which has maximum no. of Answer Count
--    Find the title and owner name of post who has got maximum no. of Comment count.
-----------------------------------------------------------------------------------------------------------
SELECT maxAnsPost.title, maxAnsPost.displayname
FROM 
(SELECT p.title , u.displayname, p.answercount
FROM rc_employee_stackoverflow.posts p
JOIN rc_employee_stackoverflow.users u ON p.owneruserid = u.id
WHERE LENGTH(NVL(p.title,0))> 0
ORDER BY p.answercount DESC
LIMIT 1 ) maxAnsPost;

SELECT maxCommentsPost.title, maxCommentsPost.displayname
FROM 
(SELECT p.title , u.displayname, p.commentcount
FROM rc_employee_stackoverflow.posts p
JOIN rc_employee_stackoverflow.users u ON p.owneruserid = u.id
WHERE LENGTH(NVL(p.title,0))> 0
ORDER BY p.commentcount DESC
LIMIT 1 ) maxCommentsPost;

-----------------------------------------------------------------------------------------------------------
-- H- Find the location which has maximum no of Stack Overflow users.
-----------------------------------------------------------------------------------------------------------
SELECT u.loc, COUNT(u.id) AS userLocCount
FROM rc_employee_stackoverflow.users u
GROUP BY u.loc
HAVING LENGTH(NVL(u.loc,0))> 0
ORDER BY userLocCount DESC
LIMIT 1;
-----------------------------------------------------------------------------------------------------------
-- I- Find the total no. of answers, posts, comments created by Indian users.
-----------------------------------------------------------------------------------------------------------
-- Find total answers
SELECT SUM(indiaUserAns.indiaUserAnsCount)
FROM 
(SELECT u.loc, COUNT(p.id) AS indiaUserAnsCount
FROM rc_employee_stackoverflow.posts p
JOIN rc_employee_stackoverflow.users u ON p.owneruserid = u.id
WHERE u.loc LIKE '%India' AND p.post_type = 2 AND LENGTH(NVL(u.loc,0))> 0
GROUP BY u.loc) indiaUserAns;

-- Find total posts (Including all kinds of posts)
SELECT SUM(indiaUserPosts.indiaUserPostsCount)
FROM 
(SELECT u.loc, COUNT(p.id) AS indiaUserPostsCount
FROM rc_employee_stackoverflow.posts p
JOIN rc_employee_stackoverflow.users u ON p.owneruserid = u.id
WHERE u.loc LIKE '%India'  AND LENGTH(NVL(u.loc,0))> 0
GROUP BY u.loc) indiaUserPosts;

-- Find total comments 
SELECT SUM(indiaUserComments.indiaUserCommentsCount)
FROM 
(SELECT u.loc, COUNT( c.id) AS indiaUserCommentsCount
FROM rc_employee_stackoverflow.comments c
JOIN rc_employee_stackoverflow.users u ON c.user_id = u.id
WHERE u.loc LIKE '%India'  AND LENGTH(NVL(u.loc,0))> 0
GROUP BY u.loc) indiaUserComments;
----------------------------------------------------------------------------------------------------------
-- Drop table: 
----------------------------------------------------------------------------------------------------------
DROP table rc_employee_stackoverflow.comments;
DROP table rc_employee_stackoverflow.posts;
DROP table rc_employee_stackoverflow.posttypes;
DROP table rc_employee_stackoverflow.users;

DROP table rc_employee_stackoverflow.usermaxrepuration;

----------------------------------------------------------------------------------------------------------
-- Drop Database: 
----------------------------------------------------------------------------------------------------------
DROP DATABASE rc_employee_stackoverflow;