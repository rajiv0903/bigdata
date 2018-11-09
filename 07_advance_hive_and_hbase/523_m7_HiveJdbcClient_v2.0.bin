import java.sql.SQLException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.DriverManager;
public class HiveJdbcClient
{
private static String driverName = "org.apache.hive.jdbc.HiveDriver";
/**
* @param args
* @throws SQLException
*/
public static void main(String args[]) throws SQLException{
try{
Class.forName(driverName);
}
catch(ClassNotFoundException e){
//TODO Auto-generated catch block
e.printStackTrace();
System.exit(1);
}
//replace "hive" here with the name of the user the queries should run
Connection con =  DriverManager.getConnection("jdbc:hive2://ip-20-0-21-85.ec2.internal:10000/default");
Statement stmt = con.createStatement();
String tableName = "testHiveDriverTable1";
stmt.execute("drop table if exists " +tableName);
stmt.execute("create table " +tableName+ "(key int, value string)");
//show tables
String sql = "show tables " +tableName+ "";
System.out.println("Running: " +sql);
ResultSet res = stmt.executeQuery(sql);
if(res.next()){
System.out.println(res.getString(1));    
}
//describe table
sql = "describe " +tableName;
System.out.println("Running: " +sql);
res = stmt.executeQuery(sql);
while(res.next()){
System.out.println(res.getString(1) + "\t" +res.getString(2));
}
}
}
