------------------------------------------------------------------------------------------------------
--Load Data using Pig Storage from hdfs file system
------------------------------------------------------------------------------------------------------
l_emp = LOAD 'pig_fileystem/employee/input/employee.dat' 
	USING PigStorage(',') AS (id:int, name:chararray, age:int, salary:int, deptid:int);

l_dept = LOAD 'pig_fileystem/employee/input/department.dat' 
	USING PigStorage(',') AS (id:int, name:chararray);

/*
--Describe the alias
*/

DESCRIBE l_emp;
DESCRIBE l_dept;

------------------------------------------------------------------------------------------------------
--Print the Data 
------------------------------------------------------------------------------------------------------
DUMP l_emp;
DUMP l_dept;

------------------------------------------------------------------------------------------------------
--Filter Employee Data by Department ID
------------------------------------------------------------------------------------------------------
f_employee = FILTER l_emp BY deptid == 3;
DESCRIBE f_employee;
DUMP f_employee;

------------------------------------------------------------------------------------------------------
--Distinct 
------------------------------------------------------------------------------------------------------
d_employee = DISTINCT f_employee;
DUMP d_employee;

------------------------------------------------------------------------------------------------------
--Foreach iteration 
------------------------------------------------------------------------------------------------------
for_emp = FOREACH l_emp GENERATE id, name, salary;
for_emp_idx = FOREACH l_emp GENERATE $1; --Starts with $0
DUMP for_emp;
DUMP for_emp_idx;

------------------------------------------------------------------------------------------------------
--Limit
------------------------------------------------------------------------------------------------------
l_emp_limited = LIMIT l_emp 3;
DESCRIBE l_emp_limited;
DUMP l_emp_limited;

------------------------------------------------------------------------------------------------------
--Stream through 
------------------------------------------------------------------------------------------------------
stream_emp = STREAM l_emp THROUGH `cut -f 1`;
DUMP stream_emp;

------------------------------------------------------------------------------------------------------
--JOIN- Inner, Outer - Left, Right, Full
------------------------------------------------------------------------------------------------------
in_join = JOIN l_emp BY deptid, l_dept BY id;
left_outer = JOIN l_emp BY deptid LEFT OUTER, l_dept BY id;
right_outer = JOIN l_emp BY deptid RIGHT OUTER, l_dept BY id;
full_outer = JOIN l_emp BY deptid FULL OUTER, l_dept BY id;

DESCRIBE in_join;
DESCRIBE left_outer;
DESCRIBE right_outer;
DESCRIBE full_outer;

DUMP in_join;
DUMP left_outer;
DUMP right_outer;
DUMP full_outer;

order_join_rec = ORDER left_outer BY l_emp::id; --Or $0
DUMP order_join_rec;

filter_join_rec= FILTER full_outer BY l_dept::name != '';
DUMP filter_join_rec;
DUMP ORDER filter_join_rec BY l_emp::id;

------------------------------------------------------------------------------------------------------
--Group
------------------------------------------------------------------------------------------------------
group_by_dept = GROUP in_join BY l_dept::id;
DESCRIBE group_by_dept;
DUMP group_by_dept;

------------------------------------------------------------------------------------------------------
--Aggregate Function - To calculate total salary for department
------------------------------------------------------------------------------------------------------
gr_by_dept =  GROUP l_emp BY deptid;
DESCRIBE gr_by_dept;
DUMP gr_by_dept;

max_sal_dept_1 = FOREACH group_by_dept GENERATE group, MAX(in_join.l_emp::salary);
DESCRIBE max_sal_dept_1;
DUMP max_sal_dept_1;

sum_sal_dept = FOREACH group_by_dept GENERATE group, SUM(in_join.l_emp::salary);
DESCRIBE sum_sal_dept;
DUMP sum_sal_dept;

max_sal_dept_2 = FOREACH gr_by_dept GENERATE group, MAX(l_emp.salary);
DESCRIBE max_sal_dept_2;
DUMP max_sal_dept_2;

max_sal_dept_3 = FOREACH (GROUP l_emp BY deptid)  GENERATE group, MAX(l_emp.salary); -- Nested Query
DESCRIBE max_sal_dept_3;
DUMP max_sal_dept_3;

------------------------------------------------------------------------------------------------------
--JOIN- Special- 
-- replicated  when one of the dataset is small to use Distributed Cache
-- merge - when both are sorted based on join key
------------------------------------------------------------------------------------------------------
r_in_join = JOIN l_emp BY deptid, l_dept BY id USING 'REPLICATED';
DESCRIBE r_in_join;
DUMP r_in_join;

l_emp_o = ORDER l_emp BY deptid;
l_dept_o = ORDER l_dept BY id;
DESCRIBE l_emp_o
DESCRIBE l_dept_o;
DUMP l_emp_o;
DUMP l_dept_o;

m_left_outer = JOIN l_emp_o BY deptid LEFT OUTER, l_dept_o BY id USING 'MERGE';
DESCRIBE m_left_outer;
DUMP m_left_outer;

------------------------------------------------------------------------------------------------------
--Store
------------------------------------------------------------------------------------------------------
STORE max_sal_dept_3 INTO 'pig_fileystem/employee/output';


------------------------------------------------------------------------------------------------------
--Union
------------------------------------------------------------------------------------------------------
un1 = LOAD 'pig_fileystem/employee/input/union_data_1.dat' AS (a1:int, a2:int); --Default is tab delimited
un2 = LOAD 'pig_fileystem/employee/input/union_data_2.dat' AS (b1:int, b2:int); --Default is tab delimited

un = UNION un1, un2;
DESCRIBE un;
DUMP un;

------------------------------------------------------------------------------------------------------
--Co Group
------------------------------------------------------------------------------------------------------
cg1 = LOAD 'pig_fileystem/employee/input/cogroup_data_1.dat' AS (a1:int, a2:int, a3:int);
cg2 = LOAD 'pig_fileystem/employee/input/cogroup_data_2.dat' AS (b1:int, b2:int);

cg = COGROUP cg1 BY a1, cg2 BY b1;
DESCRIBE cg;
DUMP cg;

