------------------------------------------------------------------------------------------------------
--Register the JAR
------------------------------------------------------------------------------------------------------
REGISTER /mnt/home/edureka_424232/pig/jars/pig-udf-practice.jar;

------------------------------------------------------------------------------------------------------
--Define the Function- It will Capitalize the String: Input:rajiv, Output: Rajiv
------------------------------------------------------------------------------------------------------
DEFINE EvalCapitalize com.practice.bigdata.hadoop.pig.assignment.Capitalize;

------------------------------------------------------------------------------------------------------
--Load Data using Pig Storage from hdfs file system
------------------------------------------------------------------------------------------------------
l_student = LOAD 'pig_fileystem/student_results/input/student'  AS (name:chararray, roll:int);
l_results = LOAD 'pig_fileystem/student_results/input/results'  AS (roll:int, result:chararray);

------------------------------------------------------------------------------------------------------
--Describe the Alias
------------------------------------------------------------------------------------------------------
DESCRIBE l_student;
DESCRIBE l_results;

------------------------------------------------------------------------------------------------------
--Dump
------------------------------------------------------------------------------------------------------
DUMP l_student;
DUMP l_results;

------------------------------------------------------------------------------------------------------
--Join the Data and Output Name and Pass Or Fail: Inner Join
------------------------------------------------------------------------------------------------------
l_join = JOIN l_student BY roll, l_results BY roll;
DESCRIBE l_join;
DUMP l_join;

------------------------------------------------------------------------------------------------------
--Iterate and Transform the Data
------------------------------------------------------------------------------------------------------
l_final_result = FOREACH l_join GENERATE CONCAT(EvalCapitalize(TRIM(l_student::name)), ' : ' ,EvalCapitalize(l_results::result));
DESCRIBE l_final_result;
DUMP l_final_result;

------------------------------------------------------------------------------------------------------
--Store
------------------------------------------------------------------------------------------------------
STORE l_final_result INTO 'pig_fileystem/student_results/output';
