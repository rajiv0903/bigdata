package com.practice.bigdata.hadoop.habase.advance;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.HConstants;
import org.apache.hadoop.hbase.KeyValue;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.util.Bytes;

public class InsertOrUpdateCustomer {

	public static void main(String[] args) throws IOException {

		Configuration config = HBaseConfiguration.create();
		config.clear();
		// config.set("hbase.zookeeper.quorum", " ip-20-0-21-196.ec2.internal");
		// config.set("hbase.zookeeper.property.clientPort", "2181");
		// config.set("hbase.master", "ip-20-0-21-196.ec2.internal:60000");
		if (args == null || args.length != 3) {
			System.err.println("Usage: <Zookeeper Host> <Zookeeper Port> <Hbase Master>");
			System.err.println("Example:  ip-20-0-21-196.ec2.internal 2181 ip-20-0-21-196.ec2.internal:60000");
			System.exit(1);
		}

		config.set("hbase.zookeeper.quorum", args[0]);
		config.set("hbase.zookeeper.property.clientPort", args[1]);
		config.set("hbase.master", args[2]);

		Connection connection = ConnectionFactory.createConnection(config);

		Table table = connection.getTable(TableName.valueOf("rc_customers"));

		List<Put> puts = new ArrayList<Put>();

		Put row1 = new Put(Bytes.toBytes("4010000"));
		KeyValue kv = new KeyValue(row1.getRow(), Bytes.toBytes("info"), Bytes.toBytes("fname"),
				HConstants.LATEST_TIMESTAMP, Bytes.toBytes("Rajiv"));
		row1.add(kv);
		kv = new KeyValue(row1.getRow(), Bytes.toBytes("info"), Bytes.toBytes("lname"), HConstants.LATEST_TIMESTAMP,
				Bytes.toBytes("Chaudhuri"));
		row1.add(kv);
		kv = new KeyValue(row1.getRow(), Bytes.toBytes("info"), Bytes.toBytes("age"), HConstants.LATEST_TIMESTAMP,
				Bytes.toBytes("33"));
		row1.add(kv);
		kv = new KeyValue(row1.getRow(), Bytes.toBytes("info"), Bytes.toBytes("prof"), HConstants.LATEST_TIMESTAMP,
				Bytes.toBytes("IT Engineer"));
		row1.add(kv);

		puts.add(row1);

		Put row2 = new Put(Bytes.toBytes("4010001"));
		kv = new KeyValue(row2.getRow(), Bytes.toBytes("info"), Bytes.toBytes("fname"), HConstants.LATEST_TIMESTAMP,
				Bytes.toBytes("Tithi"));
		row2.add(kv);
		kv = new KeyValue(row2.getRow(), Bytes.toBytes("info"), Bytes.toBytes("lname"), HConstants.LATEST_TIMESTAMP,
				Bytes.toBytes("Bose"));
		row2.add(kv);
		kv = new KeyValue(row2.getRow(), Bytes.toBytes("info"), Bytes.toBytes("age"), HConstants.LATEST_TIMESTAMP,
				Bytes.toBytes("28"));
		row2.add(kv);
		kv = new KeyValue(row2.getRow(), Bytes.toBytes("info"), Bytes.toBytes("prof"), HConstants.LATEST_TIMESTAMP,
				Bytes.toBytes("House Wife"));
		row2.add(kv);
		puts.add(row2);
		
		table.put(puts);
	}
}
