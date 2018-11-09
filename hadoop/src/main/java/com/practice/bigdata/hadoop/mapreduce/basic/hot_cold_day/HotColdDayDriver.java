package com.practice.bigdata.hadoop.mapreduce.basic.hot_cold_day;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class HotColdDayDriver {

	/*
	 * Create Mapper Class
	 */
	public static class Map extends Mapper<LongWritable, Text, Text, Text> {

		private Text day = new Text();
		private Text hotDay = new Text("Hot Day");
		private Text coldDay = new Text("Cold Day");

		private String inputDatePattern = "yyyyMMdd";
		private String outputDatePattern = "MM-dd-yyyy";

		private SimpleDateFormat simpleInputDateFormat = new SimpleDateFormat(inputDatePattern);
		private SimpleDateFormat simpleOutputDateFormat = new SimpleDateFormat(outputDatePattern);

		@Override
		protected void map(LongWritable key, Text value, Mapper<LongWritable, Text, Text, Text>.Context context)
				throws IOException, InterruptedException {

			StringTokenizer itr = new StringTokenizer(value.toString(), "\n\r"); // split based on new line
			while (itr.hasMoreTokens()) {
				String record = itr.nextToken().trim().replaceAll(" +", " ");
				String[] tokens = record.split(" "); // 63891 20130101(YYYYMMDD) 5.102 -86.61 32.85 12.8 9.6
				String date = tokens[1];
				String maxTemp = tokens[5];
				String minTemp = tokens[6];
				// System.out.println("<date, maxTemp, minTemp>:<" + date + "," + maxTemp + ","
				// + minTemp + ">");
				try {
					date = simpleOutputDateFormat.format(simpleInputDateFormat.parse(date));
				} catch (ParseException e) {
				}
				day.set(date); // 01-01-2013

				if (Float.parseFloat(maxTemp) - 40 > 0) {
					context.write(day, hotDay);
				} else if (Float.parseFloat(minTemp) - 10 < 0) {
					context.write(day, coldDay);
				}
			}
		}
	}

	public static void main(String[] args) throws Exception {

		if (args == null || args.length != 2) {
			System.out.println("Usage: <input directory path> <output directory path>");
			System.exit(1);
		}

		// Take Default Configuration
		Configuration conf = new Configuration();
		// Create a Map Reduce JOB
		Job job = Job.getInstance(conf, "hot_cold_day");

		// Set the JAR Class- To prevent Class Not found exception
		job.setJarByClass(com.practice.bigdata.hadoop.mapreduce.basic.hot_cold_day.HotColdDayDriver.class);

		// Configure Mapper and Reducer (Semi-Reducer: Combiner) Class- No Reducer
		job.setMapperClass(com.practice.bigdata.hadoop.mapreduce.basic.hot_cold_day.HotColdDayDriver.Map.class);
		job.setNumReduceTasks(0);

		// Set Output Key Class and Value Class
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(IntWritable.class);

		// Construct Path from user intput
		Path input = new Path(args[0]);
		Path output = new Path(args[1]);

		// Delete existing directory
		FileSystem fs = FileSystem.get(conf);
		if (fs.exists(output)) {
			fs.delete(output, true);
		}

		// Configure the HDFS input file path and output file path
		FileInputFormat.addInputPath(job, input);
		FileOutputFormat.setOutputPath(job, output);

		// Wait for the completion - Print the Progress - Pass true
		System.exit(job.waitForCompletion(true) ? 0 : 1);

	}
}
