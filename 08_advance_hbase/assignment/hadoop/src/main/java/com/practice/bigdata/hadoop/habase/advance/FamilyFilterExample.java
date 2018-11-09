package com.practice.bigdata.hadoop.habase.advance;

import java.io.IOException;
import java.util.Random;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.HColumnDescriptor;
import org.apache.hadoop.hbase.HTableDescriptor;
import org.apache.hadoop.hbase.KeyValue;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.HBaseAdmin;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.ResultScanner;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.filter.BinaryComparator;
import org.apache.hadoop.hbase.filter.CompareFilter;
import org.apache.hadoop.hbase.filter.FamilyFilter;
import org.apache.hadoop.hbase.filter.Filter;
import org.apache.hadoop.hbase.filter.QualifierFilter;
import org.apache.hadoop.hbase.filter.SubstringComparator;
import org.apache.hadoop.hbase.filter.ValueFilter;
import org.apache.hadoop.hbase.util.Bytes;

public class FamilyFilterExample {

	private static Configuration conf = HBaseConfiguration.create();
	private static String tableName= "rc_testtable";
	private static Connection connection;
	static {
		try {
			conf.set("hbase.zookeeper.quorum", " ip-20-0-21-196.ec2.internal");
			conf.set("hbase.zookeeper.property.clientPort", "2181");
			conf.set("hbase.master", "ip-20-0-21-196.ec2.internal:60000");
			connection = ConnectionFactory.createConnection(conf);
		} catch (IOException exe) {
			System.err.println(exe);
		}
	}

	static void disableTable(String table) throws IOException {
		HBaseAdmin admin = (HBaseAdmin)connection.getAdmin();
		admin.disableTable(table);
	}

	public static void dropTable(String table) throws IOException {
		HBaseAdmin admin = (HBaseAdmin)connection.getAdmin();
		Connection connection = ConnectionFactory.createConnection(conf);

		Table tbl = connection.getTable(TableName.valueOf(tableName));
		if (admin.tableExists(table)) {
			disableTable(table);
			admin.deleteTable(TableName.valueOf(tableName));
		}
	}

	public static void createTable(String table, String... colfams) throws IOException {
		HBaseAdmin admin = new HBaseAdmin(conf);
		HTableDescriptor desc = new HTableDescriptor(table);
		for (String cf : colfams) {
			HColumnDescriptor coldef = new HColumnDescriptor(cf);
			desc.addFamily(coldef);
		}
		admin.createTable(desc);
	}

	public static void fillTable(String table, int startRow, int endRow, int numCols, int pad, boolean setTimestamp,
			boolean random, String... colfams) throws IOException {

		HTable tbl = new HTable(conf, table);
		Random rnd = new Random();
		for (int row = startRow; row <= endRow; row++) {
			for (int col = 0; col < numCols; col++) {
				Put put = new Put(Bytes.toBytes("row-" + padNum(row, pad)));
				for (String cf : colfams) {
					String colName = "col-" + padNum(col, pad);
					String val = "val-" + (random ? Integer.toString(rnd.nextInt(numCols))
							: padNum(row, pad) + "." + padNum(col, pad));
					if (setTimestamp) {
						put.add(Bytes.toBytes(cf), Bytes.toBytes(colName), col, Bytes.toBytes(val));
					} else {
						put.add(Bytes.toBytes(cf), Bytes.toBytes(colName), Bytes.toBytes(val));
					}
				}
				tbl.put(put);
			}
		}
		tbl.close();

	}

	public static String padNum(int num, int pad) {
		String res = Integer.toString(num);
		if (pad > 0) {
			while (res.length() < pad) {
				res = "0" + res;
			}
		}
		return res;
	}

	@SuppressWarnings("deprecation")
	public static void main(String[] args) throws IOException {

		Configuration conf = HBaseConfiguration.create();
		conf.set("hbase.zookeeper.quorum", "ip-20-0-21-196.ec2.internal");
		conf.set("hbase.zookeeper.property.clientPort", "2181");
		conf.set("hbase.master", "ip-20-0-21-196.ec2.internal:60000");

		FamilyFilterExample.dropTable(tableName);
		FamilyFilterExample.createTable(tableName, "colfam1", "colfam2", "colfam3", "colfam4");
		System.out.println("Adding rows to table...");

		FamilyFilterExample.fillTable(tableName, 1, 10, 2, -1, false, false, "colfam1", "colfam2", "colfam3",
				"colfam4");

		HTable table = new HTable(conf, tableName);

		System.out.println("***************************************************************");
		System.out.println("****using a filter to include only specific column families****");
		System.out.println("***************************************************************");

		Filter filter1 = new FamilyFilter(CompareFilter.CompareOp.LESS, new BinaryComparator(Bytes.toBytes("colfam2")));
		Scan scan = new Scan();
		scan.setFilter(filter1);
		ResultScanner scanner = table.getScanner(scan);
		System.out.println("Scanning table... ");
		for (Result result : scanner) {
			System.out.println(result);
		}
		scanner.close();

		Get get1 = new Get(Bytes.toBytes("row-5"));
		get1.setFilter(filter1);
		Result result1 = table.get(get1);
		System.out.println("Result of get(): " + result1);

		Filter filter2 = new FamilyFilter(CompareFilter.CompareOp.EQUAL,
				new BinaryComparator(Bytes.toBytes("colfam3")));
		Get get2 = new Get(Bytes.toBytes("row-5"));
		get2.addFamily(Bytes.toBytes("colfam1"));
		get2.setFilter(filter2);
		Result result2 = table.get(get2);
		System.out.println("Result of get(): " + result2);

		System.out.println("***************************************************************");
		System.out.println("***using a filter to include only specific column qualifiers***");
		System.out.println("***************************************************************");

		Filter filter3 = new QualifierFilter(CompareFilter.CompareOp.LESS_OR_EQUAL,
				new BinaryComparator(Bytes.toBytes("col-2")));

		Scan scan1 = new Scan();
		scan1.setFilter(filter3);
		ResultScanner scanner1 = table.getScanner(scan1);
		System.out.println("Scanning table... ");
		for (Result result : scanner1) {
			System.out.println(result);
		}
		scanner1.close();

		Get get = new Get(Bytes.toBytes("row-5"));
		get.setFilter(filter3);
		Result result = table.get(get);
		System.out.println("Result of get(): " + result);
		System.out.println("***************************************************************");
		System.out.println("*****************using the value based filter******************");
		System.out.println("***************************************************************");

		Filter filter = new ValueFilter(CompareFilter.CompareOp.EQUAL, new SubstringComparator(".0"));
		Scan scan11 = new Scan();
		scan11.setFilter(filter);
		ResultScanner scanner11 = table.getScanner(scan11);
		System.out.println("Results of scan:");
		for (Result result11 : scanner11) {
			for (KeyValue kv : result11.raw()) {
				System.out.println("KV: " + kv + ", Value: " + Bytes.toString(kv.getValue()));
			}
		}
		scanner11.close();
		Get get11 = new Get(Bytes.toBytes("row-5"));
		get11.setFilter(filter);
		Result result11 = table.get(get11);
		System.out.println("Result of get: ");
		for (KeyValue kv : result11.raw()) {
			System.out.println("KV: " + kv + ", Value: " + Bytes.toString(kv.getValue()));
		}

	}
}
