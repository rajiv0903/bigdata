package com.practice.bigdata.hadoop.mapreduce.basic.max_temp;

import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class MaxTempDriver {

	/*
	 * Create Mapper Class
	 */
	public static class Map extends Mapper<LongWritable, Text, Text, IntWritable> {

		private IntWritable temp = new IntWritable();
		private Text word = new Text();

		@Override
		protected void map(LongWritable key, Text value, Mapper<LongWritable, Text, Text, IntWritable>.Context context)
				throws IOException, InterruptedException {

			StringTokenizer itr = new StringTokenizer(value.toString(), "\n\r"); // split based on new line
			while (itr.hasMoreTokens()) {
				String token = itr.nextToken();
				String[] yearTemp = token.split(" ");
				word.set(yearTemp[0]); // 1990 38
				temp.set(Integer.parseInt(yearTemp[1]));
				// System.out.println("Map Output<K,V>:<" + word.toString() + "," + temp.get()
				// +">");
				context.write(word, temp);
			}
		}
	}

	/*
	 * Create Reducer Class
	 */
	public static class Reduce extends Reducer<Text, IntWritable, Text, IntWritable> {

		private IntWritable result = new IntWritable();

		@Override
		public void reduce(Text key, Iterable<IntWritable> values, Context context)
				throws IOException, InterruptedException {

			int maxValue = 0;
			// Looping and calculating Max for each year
			for (IntWritable val : values) {
				maxValue = Math.max(maxValue, val.get());
			}
			result.set(maxValue);
			// System.out.println("Reduce Output<K,V>:<" + key.toString() + "," +
			// result.get() + ">");
			context.write(key, result);
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
		Job job = Job.getInstance(conf, "max_temp");

		// Set the JAR Class- To prevent Class Not found exception
		job.setJarByClass(com.practice.bigdata.hadoop.mapreduce.basic.max_temp.MaxTempDriver.class);

		// Configure Mapper and Reducer (Semi-Reducer: Combiner) Class
		job.setMapperClass(com.practice.bigdata.hadoop.mapreduce.basic.max_temp.MaxTempDriver.Map.class);
		job.setCombinerClass(com.practice.bigdata.hadoop.mapreduce.basic.max_temp.MaxTempDriver.Reduce.class);
		job.setReducerClass(com.practice.bigdata.hadoop.mapreduce.basic.max_temp.MaxTempDriver.Reduce.class);
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
