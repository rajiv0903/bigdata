----------------------------------------------------------------------------------------------------------
-- https://www.tutorialspoint.com/hbase/index.htm
--Get the status
--Case Sensitive
----------------------------------------------------------------------------------------------------------
status
----------------------------------------------------------------------------------------------------------
--Get the version
----------------------------------------------------------------------------------------------------------
version
----------------------------------------------------------------------------------------------------------
--Get user info
----------------------------------------------------------------------------------------------------------
whoami
----------------------------------------------------------------------------------------------------------
--List of tables
----------------------------------------------------------------------------------------------------------
list
----------------------------------------------------------------------------------------------------------
--List of tables
----------------------------------------------------------------------------------------------------------
exists 'rc_employee'
----------------------------------------------------------------------------------------------------------
--Create Table
----------------------------------------------------------------------------------------------------------
create 'rc_employee', {NAME=>'personal', VERSIONS=>5}
describe 'rc_employee'
----------------------------------------------------------------------------------------------------------
--Insert Data
----------------------------------------------------------------------------------------------------------
put 'rc_employee', 'emp1', 'personal:name', 'Rajiv'
put 'rc_employee', 'emp1', 'personal:age', '32'
put 'rc_employee', 'emp1', 'personal:password', 'abc123'

put 'rc_employee', 'emp2', 'personal:name', 'Deb'
put 'rc_employee', 'emp2', 'personal:age', '34'
put 'rc_employee', 'emp2', 'personal:password', 'abc123'

put 'rc_employee', 'emp3', 'personal:name', 'Prat'
put 'rc_employee', 'emp3', 'personal:age', '33'
put 'rc_employee', 'emp3', 'personal:password', 'abc123'

----------------------------------------------------------------------------------------------------------
--See Table Data
----------------------------------------------------------------------------------------------------------
scan 'rc_employee'
----------------------------------------------------------------------------------------------------------
--Get Specific Row by Row Key
----------------------------------------------------------------------------------------------------------
get 'rc_employee', 'emp1'

----------------------------------------------------------------------------------------------------------
--Add New Column Family: First Disable the Table
----------------------------------------------------------------------------------------------------------
disable 'rc_employee'
alter 'rc_employee', {NAME=>'address', VERSIONS=>5}
enable 'rc_employee'

----------------------------------------------------------------------------------------------------------
--Update Data
----------------------------------------------------------------------------------------------------------
put 'rc_employee', 'emp1', 'personal:password', 'xyz123'
get 'rc_employee', 'emp1'
----------------------------------------------------------------------------------------------------------
--Add New Data
----------------------------------------------------------------------------------------------------------
put 'rc_employee', 'emp1', 'address:street', 'San Moritz'
put 'rc_employee', 'emp1', 'address:city', 'Herndon'
put 'rc_employee', 'emp1', 'address:state', 'Virginia'
put 'rc_employee', 'emp1', 'address:country', 'USA'

put 'rc_employee', 'emp2', 'address:street', 'Fontainebleau Blvd'
put 'rc_employee', 'emp2', 'address:city', 'Miami'
put 'rc_employee', 'emp2', 'address:state', 'Florida'
put 'rc_employee', 'emp2', 'address:country', 'USA'

----------------------------------------------------------------------------------------------------------
--Table Help
----------------------------------------------------------------------------------------------------------
table_help

----------------------------------------------------------------------------------------------------------
--Delete Record
----------------------------------------------------------------------------------------------------------
delete 'rc_employee', 'emp3', 'personal:city'
deleteall  'rc_employee', 'emp3'
----------------------------------------------------------------------------------------------------------
--Drop Table
----------------------------------------------------------------------------------------------------------
disable 'rc_employee'
drop 'rc_employee'