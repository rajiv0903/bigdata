package com.practice.bigdata.hadoop.habase.rest;

import java.io.IOException;

import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.ResultScanner;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.rest.client.Client;
import org.apache.hadoop.hbase.rest.client.Cluster;
import org.apache.hadoop.hbase.rest.client.RemoteHTable;
import org.apache.hadoop.hbase.util.Bytes;

public class HBaseRestClient {

	private static String tableName = "rc_customers";
	
	public static void main(String[] args) throws IOException {
		
		if (args == null || args.length != 2) {
			System.err.println("Usage: <Zookeeper Host> <Rest Port>");
			System.err.println("Example:  ip-20-0-21-196.ec2.internal 20550");
			System.exit(1);
		}
		
		Cluster cluster = new Cluster();
		cluster.add(args[0], Integer.parseInt(args[1].trim()));
		
		Client client = new Client(cluster);
		RemoteHTable table = new RemoteHTable(client, tableName);
		Get get = new Get(Bytes.toBytes("4000010"));
		get.addColumn(Bytes.toBytes("info"), Bytes.toBytes("fname"));
		
		Result result1 = table.get(get);
		System.out.println("Get result1: " + result1);
		Scan scan = new Scan();
		scan.setStartRow(Bytes.toBytes("4000002"));
		scan.setStopRow(Bytes.toBytes("4000013"));
		scan.addColumn(Bytes.toBytes("info"), Bytes.toBytes("fname"));

		ResultScanner scanner = table.getScanner(scan);
		System.out.println("Scan Started");
		for (Result result2 : scanner) {
			System.out.println("Scan row[" + Bytes.toString(result2.getRow()) + "]: " + result2);
		}
	}
}
