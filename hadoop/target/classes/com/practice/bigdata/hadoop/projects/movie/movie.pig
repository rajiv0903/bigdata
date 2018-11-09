------------------------------------------------------------------------------------------------------
-- Prerequisite: 
-- Make HDFS File System and Load Input Data to HDFS
-- hdfs dfs -mkdir project_filesystem
-- hdfs dfs -mkdir project_filesystem/movie
-- hdfs dfs -mkdir project_filesystem/movie/input
-- hdfs dfs -mkdir project_filesystem/movie/output
-- hdfs dfs -copyFromLocal projects/movie/artifacts/movies_dataset_for_pig.txt  project_filesystem/movie/input
-- hdfs dfs -ls project_filesystem/movie
-- hdfs dfs -ls project_filesystem/movie/input
------------------------------------------------------------------------------------------------------
-- Load Data using Pig Storage from hdfs file system
-- Pig Shell: pig
------------------------------------------------------------------------------------------------------
l_movies = LOAD 'project_filesystem/movie/input/movies_dataset_for_pig.txt'  using PigStorage(',') 
		AS (id:int, name:chararray, release:int, rating:double, duration:int);

------------------------------------------------------------------------------------------------------
-- Describe the Alias
-- 		DESCRIBE l_movies;
-- Dump limited Data
-- 		l_movies_limit = LIMIT l_movies 4; 
-- 		DUMP l_movies_limit;
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
-- A. Find the number of movies released between 1950 and 1960.
--DESCRIBE l_sol_a;
--DUMP l_sol_a;
------------------------------------------------------------------------------------------------------
l_sol_a = FILTER l_movies BY release >= 1950 AND release <= 1960;
STORE l_sol_a INTO 'project_filesystem/movie/output/solution_a';

------------------------------------------------------------------------------------------------------
-- B. Find the number of movies having rating more than 4.
-- DESCRIBE l_sol_b;
-- DUMP l_sol_b;
------------------------------------------------------------------------------------------------------
l_sol_b = FILTER l_movies BY rating > 4;
STORE l_sol_b INTO 'project_filesystem/movie/output/solution_b';

------------------------------------------------------------------------------------------------------
-- C. Find the movies whose rating are between 3 and 4.
-- DESCRIBE l_sol_c;
-- DUMP l_sol_c;
------------------------------------------------------------------------------------------------------
l_sol_c = FILTER l_movies BY rating >= 3 AND rating <= 4;
STORE l_sol_c INTO 'project_filesystem/movie/output/solution_c';

------------------------------------------------------------------------------------------------------
-- D. Find the number of movies with duration more than 2 hours (7200 second).
-- DESCRIBE l_sol_d;
-- DUMP l_sol_d;
------------------------------------------------------------------------------------------------------
l_sol_d = FILTER l_movies BY duration > 7200 ;
STORE l_sol_d INTO 'project_filesystem/movie/output/solution_d';

------------------------------------------------------------------------------------------------------
-- E. Find the list of years and number of movies released each year.
-- DESCRIBE l_sol_e;
-- DUMP l_sol_e;
------------------------------------------------------------------------------------------------------
l_sol_e = FOREACH (GROUP l_movies BY release)  GENERATE group, COUNT(l_movies.id); 
STORE l_sol_e INTO 'project_filesystem/movie/output/solution_e';

------------------------------------------------------------------------------------------------------
-- F. Find the total number of movies in the dataset.
-- DESCRIBE l_sol_f;
-- DUMP l_sol_f;
------------------------------------------------------------------------------------------------------
l_sol_f = FOREACH (GROUP l_movies ALL) GENERATE COUNT(l_movies);
STORE l_sol_f INTO 'project_filesystem/movie/output/solution_f';
