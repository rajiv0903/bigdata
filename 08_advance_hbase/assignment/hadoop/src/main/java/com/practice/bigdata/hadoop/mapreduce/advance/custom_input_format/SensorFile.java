package com.practice.bigdata.hadoop.mapreduce.advance.custom_input_format;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class SensorFile {

	public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

		if (args.length != 2) {
			System.err.println("Usage: <input path> <output path>");
			System.exit(1);
		}
		Configuration conf = new Configuration();
		Job job = Job.getInstance(conf, "Sensor_Custom_Input_Format");
		job.setJarByClass(com.practice.bigdata.hadoop.mapreduce.advance.custom_input_format.SensorFile.class);
		job.setNumReduceTasks(0);
		job.setMapperClass(com.practice.bigdata.hadoop.mapreduce.advance.custom_input_format.SensorMapper.class);
		job.setMapOutputKeyClass(Text.class);
		job.setMapOutputValueClass(Text.class);
		job.setInputFormatClass(
				com.practice.bigdata.hadoop.mapreduce.advance.custom_input_format.SensorInputFormat.class);

		Path input = new Path(args[0]);
		Path output = new Path(args[1]);
		
		FileInputFormat.addInputPath(job, input);
		FileOutputFormat.setOutputPath(job,output);
		
		FileSystem.get(conf).delete(output, true);

		System.exit(job.waitForCompletion(true)? 0: 1);
	}
}