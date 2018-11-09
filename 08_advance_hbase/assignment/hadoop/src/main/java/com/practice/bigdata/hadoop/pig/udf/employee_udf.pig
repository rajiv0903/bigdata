------------------------------------------------------------------------------------------------------
--Register the JAR
------------------------------------------------------------------------------------------------------
REGISTER /mnt/home/edureka_424232/pig/jars/pig-udf-practice.jar;

------------------------------------------------------------------------------------------------------
--Define the Function
------------------------------------------------------------------------------------------------------
DEFINE FilterAge com.practice.bigdata.hadoop.pig.udf.IsAdult;
DEFINE EvalUpper com.practice.bigdata.hadoop.pig.udf.ToUpper;

------------------------------------------------------------------------------------------------------
--Load Data using Pig Storage from hdfs file system
------------------------------------------------------------------------------------------------------
l_emp = LOAD 'pig_fileystem/udf/input/employee_udf.dat' 
	USING PigStorage(',') AS (id:int, name:chararray, age:int, salary:int, deptid:int);
	
------------------------------------------------------------------------------------------------------
--Filter By Age
------------------------------------------------------------------------------------------------------
A = FILTER l_emp BY FilterAge(age);
B = FILTER l_emp BY com.practice.bigdata.hadoop.pig.udf.IsAdult(age);

DESCRIBE A;
DESCRIBE B;

DUMP A;
DUMP B;

------------------------------------------------------------------------------------------------------
--Convert Name
------------------------------------------------------------------------------------------------------
C = FOREACH l_emp GENERATE EvalUpper(name);
D = FOREACH l_emp GENERATE com.practice.bigdata.hadoop.pig.udf.ToUpper(name);

DESCRIBE C;
DESCRIBE D;

DUMP C;
DUMP D;