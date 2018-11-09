package com.practice.bigdata.hadoop.habase.advance;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.CellUtil;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.util.Bytes;


public class GetCustomer {

	private static String tableName = "rc_customers";
	
	public static void main(String[] args) throws IOException {

		Configuration config = HBaseConfiguration.create();
		config.clear();
		if (args == null || args.length != 3) {
			System.err.println("Usage: <Zookeeper Host> <Zookeeper Port> <Hbase Master>");
			System.err.println("Example:  ip-20-0-21-196.ec2.internal 2181 ip-20-0-21-196.ec2.internal:60000");
			System.exit(1);
		}
		
		config.set("hbase.zookeeper.quorum", args[0]);
		config.set("hbase.zookeeper.property.clientPort", args[1]);
		config.set("hbase.master", args[2]);

		Connection connection = ConnectionFactory.createConnection(config);

		Table table = connection.getTable(TableName.valueOf(tableName));

		// GetListExample
		byte[] cf1 = Bytes.toBytes("info");
		byte[] qf1 = Bytes.toBytes("fname");
		byte[] qf2 = Bytes.toBytes("lname");
		byte[] row1 = Bytes.toBytes("4005000");
		byte[] row2 = Bytes.toBytes("4009000");

		List<Get> gets = new ArrayList<Get>();

		Get get1 = new Get(row1); // Row Key
		get1.addColumn(cf1, qf1); // Column Family and Column Qualifier
		gets.add(get1);

		Get get2 = new Get(row2); // Row Key
		get2.addColumn(cf1, qf1); // Column Family and Column Qualifier
		gets.add(get2);

		Get get3 = new Get(row2); // Row Key
		get3.addColumn(cf1, qf2); // Column Family and Column Qualifier
		gets.add(get3);

		Result[] results = table.get(gets);

		System.out.println("First iteration...");
		for (Result result : results) {
			String row = Bytes.toString(result.getRow());
			System.out.print("Row: " + row + " ");
			byte[] val = null;
			if (result.containsColumn(cf1, qf1)) { // Column Family and Column Qualifier
				val = result.getValue(cf1, qf1);
				System.out.println("Value: " + Bytes.toString(val));
			}
			if (result.containsColumn(cf1, qf2)) { // Column Family and Column Qualifier
				val = result.getValue(cf1, qf2);
				System.out.println("Value: " + Bytes.toString(val));
			}
		}

		System.out.println("Second iteration...");
		for (Result result : results) {
			for (Cell cell : result.listCells()) {
				String row = new String(CellUtil.cloneRow(cell));
				String family = new String(CellUtil.cloneFamily(cell));
				String column = new String(CellUtil.cloneQualifier(cell));
				String value = new String(CellUtil.cloneValue(cell));
				long timestamp = cell.getTimestamp();
				System.out.printf("%-20s column=%s:%s, timestamp=%s, value=%s\n", 
						row, family, column, timestamp,
						value);

				System.out.println("Row: " + Bytes.toString(CellUtil.cloneQualifier(cell)) + " Value: "
						+ Bytes.toString(CellUtil.cloneValue(cell)));
			}
		}

	}
}
