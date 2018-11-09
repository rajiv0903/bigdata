package com.practice.bigdata.hadoop.mapreduce.advance.reduce_side_join;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.MultipleInputs;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class CustomerTotalTransactionDriver {

	public static class CustomerMapper extends Mapper<LongWritable, Text, Text, Text> {

		private Text custId = new Text();
		private Text mapValue = new Text();

		@Override
		protected void map(LongWritable key, Text value, Mapper<LongWritable, Text, Text, Text>.Context context)
				throws IOException, InterruptedException {

			// Data:
			// 4000001,Kristina,Chung,55,Pilot
			/*
			 * For each Record - Map as Customer ID - custs\t<name>
			 */
			String record = value.toString();
			String parts[] = record.split(",");
			custId.set(parts[0]);
			mapValue.set("custs\t" + parts[1]);
			context.write(custId, mapValue);
		}
	}

	public static class TransactionMapper extends Mapper<LongWritable, Text, Text, Text> {

		private Text custId = new Text();
		private Text mapValue = new Text();

		@Override
		protected void map(LongWritable key, Text value, Mapper<LongWritable, Text, Text, Text>.Context context)
				throws IOException, InterruptedException {

			// Data:
			// 00000000,06-26-2011,4000001,040.33,Exercise &
			/*
			 * For each Record - Map as Customer ID - txns\t<amount>
			 */
			String record = value.toString();
			String parts[] = record.split(",");
			custId.set(parts[2]);
			mapValue.set("txns\t" + parts[3]);
			context.write(custId, mapValue);
		}
	}

	public static class Reduce extends Reducer<Text, Text, Text, Text> {

		@Override
		protected void reduce(Text key, Iterable<Text> values, Reducer<Text, Text, Text, Text>.Context context)
				throws IOException, InterruptedException {

			/*
			 * Iterate through each record - Relying on Sorting and Shuffling process We
			 * will get the custID as key and Iterable values will have customer name
			 * Transaction details
			 */
			String custName = "";
			double txnsTotal = 0;
			int txnsCount = 0;

			for (Text t : values) {
				String parts[] = t.toString().split("\t"); // Value from Mapper \t separated
				if (parts[0].equals("txns")) {
					txnsCount++;
					txnsTotal += Float.parseFloat(parts[1]);
				} else if (parts[0].equals("custs")) {
					custName = parts[1];
				}
			}
			String str = String.format("%d\t%f", txnsCount, txnsTotal);
			context.write(new Text(custName), new Text(str));
		}
	}

	public static void main(String[] args) throws Exception {

		if (args == null || args.length != 3) {
			System.out.println("Usage: <input cutomer direcory> <input transaction directory> "
					+ "<output transaction directory>");
			System.exit(1);
		}

		Configuration conf = new Configuration(); // Load default configuration
		Job job = Job.getInstance(conf, "customer_transac_reduce_side_join");
		job.setJarByClass(
				com.practice.bigdata.hadoop.mapreduce.advance.reduce_side_join.CustomerTotalTransactionDriver.class);

		job.setReducerClass(
				com.practice.bigdata.hadoop.mapreduce.advance.reduce_side_join.CustomerTotalTransactionDriver.Reduce.class);

		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);

		Path custInputPath = new Path(args[0]);
		Path txnInputPath = new Path(args[1]);
		Path outputPath = new Path(args[2]);

		MultipleInputs.addInputPath(job, custInputPath, TextInputFormat.class,
				com.practice.bigdata.hadoop.mapreduce.advance.reduce_side_join.CustomerTotalTransactionDriver.CustomerMapper.class);
		MultipleInputs.addInputPath(job, txnInputPath, TextInputFormat.class,
				com.practice.bigdata.hadoop.mapreduce.advance.reduce_side_join.CustomerTotalTransactionDriver.TransactionMapper.class);

		FileOutputFormat.setOutputPath(job, outputPath);
		
		FileSystem.get(conf).delete(outputPath, true);
		
		System.exit(job.waitForCompletion(true) ? 0 : 1);
	}

}
