package com.practice.bigdata.hadoop.habase.advance;

import java.io.IOException;
import java.util.Random;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.CellUtil;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.HColumnDescriptor;
import org.apache.hadoop.hbase.HConstants;
import org.apache.hadoop.hbase.HTableDescriptor;
import org.apache.hadoop.hbase.KeyValue;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Admin;
import org.apache.hadoop.hbase.client.ColumnFamilyDescriptorBuilder;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.ResultScanner;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.client.TableDescriptor;
import org.apache.hadoop.hbase.client.TableDescriptorBuilder;
import org.apache.hadoop.hbase.filter.BinaryComparator;
import org.apache.hadoop.hbase.filter.CompareFilter;
import org.apache.hadoop.hbase.filter.FamilyFilter;
import org.apache.hadoop.hbase.filter.Filter;
import org.apache.hadoop.hbase.filter.QualifierFilter;
import org.apache.hadoop.hbase.filter.SubstringComparator;
import org.apache.hadoop.hbase.filter.ValueFilter;
import org.apache.hadoop.hbase.regionserver.DefaultStoreEngine;
import org.apache.hadoop.hbase.regionserver.DisabledRegionSplitPolicy;
import org.apache.hadoop.hbase.regionserver.compactions.FIFOCompactionPolicy;
import org.apache.hadoop.hbase.util.Bytes;

public class FamilyFilterExample {

	private static Configuration conf;
	private static String tableName = "rc_testtable";
	private static Connection connection;

	static Configuration initConfiguration(String[] args) {
		if (conf == null)
			conf = HBaseConfiguration.create();
		conf.clear();
		conf.set("hbase.zookeeper.quorum", args[0]);
		conf.set("hbase.zookeeper.property.clientPort", args[1]);
		conf.set("hbase.master", args[2]);
		return conf;
	}

	static Connection getConnection() {
		if (connection == null) {
			try {
				connection = ConnectionFactory.createConnection(conf);
			} catch (IOException exe) {
				System.err.println(exe);
			}
		}
		return connection;
	}

	static void disableTable(String table) throws IOException {
		Admin admin = getConnection().getAdmin();
		admin.disableTable(TableName.valueOf(tableName));
	}

	public static void dropTable(String table) throws IOException {

		Admin admin = getConnection().getAdmin();
		if (admin.tableExists(TableName.valueOf(tableName))) {
			disableTable(table);
			admin.deleteTable(TableName.valueOf(tableName));
		}
	}

	public static void createTable(String table, String... colfams) throws IOException {

		Admin admin = getConnection().getAdmin();

		TableDescriptorBuilder tblDescBuilder = TableDescriptorBuilder.newBuilder(TableName.valueOf(tableName));

		for (String cf : colfams) {
			tblDescBuilder.setColumnFamily(ColumnFamilyDescriptorBuilder.newBuilder(Bytes.toBytes(cf)).build());
		}
		tblDescBuilder.setValue(DefaultStoreEngine.DEFAULT_COMPACTION_POLICY_CLASS_KEY,
				FIFOCompactionPolicy.class.getName());
		tblDescBuilder.setValue(HConstants.HBASE_REGION_SPLIT_POLICY_KEY, DisabledRegionSplitPolicy.class.getName());

		TableDescriptor desc = tblDescBuilder.build();
		admin.createTable(desc);
	}

	public static void fillTable(String table, int startRow, int endRow, int numCols, int pad, boolean setTimestamp,
			boolean random, String... colfams) throws IOException {

		Table tbl = getConnection().getTable(TableName.valueOf(tableName));

		Random rnd = new Random();
		for (int row = startRow; row <= endRow; row++) {

			for (int col = 0; col < numCols; col++) {
				Put put = new Put(Bytes.toBytes("row-" + padNum(row, pad)));

				for (String cf : colfams) {
					String colName = "col-" + padNum(col, pad);
					String val = "val-" + (random ? Integer.toString(rnd.nextInt(numCols))
							: padNum(row, pad) + "." + padNum(col, pad));

					KeyValue kv;
					if (setTimestamp) {
						kv = new KeyValue(put.getRow(), Bytes.toBytes(cf), Bytes.toBytes(colName), (long) col,
								Bytes.toBytes(val));
						put.add(kv);

					} else {
						kv = new KeyValue(put.getRow(), Bytes.toBytes(cf), Bytes.toBytes(colName), Bytes.toBytes(val));
						put.add(kv);
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

	public static void main(String[] args) throws IOException {

		if (args == null || args.length != 3) {
			System.err.println("Usage: <Zookeeper Host> <Zookeeper Port> <Hbase Master>");
			System.err.println("Example:  ip-20-0-21-196.ec2.internal 2181 ip-20-0-21-196.ec2.internal:60000");
			System.exit(1);
		}
		initConfiguration(args);
		getConnection();

		FamilyFilterExample.dropTable(tableName);
		FamilyFilterExample.createTable(tableName, "colfam1", "colfam2", "colfam3", "colfam4");
		System.out.println("Adding rows to table...");

		FamilyFilterExample.fillTable(tableName, 1, 10, 2, -1, false, false, "colfam1", "colfam2", "colfam3",
				"colfam4");

		Table table = getConnection().getTable(TableName.valueOf(tableName));

		System.out.println("***************************************************************");
		System.out.println("****Using a filter to include only specific column families****");
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
		System.out.println("***Using a filter to include only specific column qualifiers***");
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
		System.out.println("*****************Using the value based filter******************");
		System.out.println("***************************************************************");

		Filter filter = new ValueFilter(CompareFilter.CompareOp.EQUAL, new SubstringComparator(".0"));
		Scan scan11 = new Scan();
		scan11.setFilter(filter);
		ResultScanner scanner11 = table.getScanner(scan11);
		System.out.println("Results of scan:");
		for (Result result11 : scanner11) {
			for (Cell cell : result11.listCells()) {
				System.out.println("Row: " + Bytes.toString(CellUtil.cloneQualifier(cell)) + " Value: "
						+ Bytes.toString(CellUtil.cloneValue(cell)));
			}
		}
		scanner11.close();
		Get get11 = new Get(Bytes.toBytes("row-5"));
		get11.setFilter(filter);
		Result result11 = table.get(get11);
		System.out.println("Result of get: ");
		for (Cell cell : result11.listCells()) {
			System.out.println("Row: " + Bytes.toString(CellUtil.cloneQualifier(cell)) + " Value: "
					+ Bytes.toString(CellUtil.cloneValue(cell)));
		}

	}
}
