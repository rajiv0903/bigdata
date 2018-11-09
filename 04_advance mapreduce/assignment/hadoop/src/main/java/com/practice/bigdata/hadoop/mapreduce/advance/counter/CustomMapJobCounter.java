package com.practice.bigdata.hadoop.mapreduce.advance.counter;

import java.io.IOException;
import java.util.Calendar;
import java.util.Date;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Counter;
import org.apache.hadoop.mapreduce.Counters;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.JobStatus;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class CustomMapJobCounter {

	public static enum MONTH {
		DEC, JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV
	};

	public static class Map extends Mapper<LongWritable, Text, Text, Text> {
		private Text out = new Text();

		@Override
		protected void map(LongWritable key, Text value, Context context)
				throws java.io.IOException, InterruptedException {
			String line = value.toString();
			String[] strts = line.split(",");
			long lts = Long.parseLong(strts[1]);
			Date time = new Date(lts);
			Calendar cl = Calendar.getInstance();
			cl.setTime(time);
			int m = cl.get(Calendar.MONTH);
			System.out.println("Month:" + m);
			switch (m) {
			case Calendar.DECEMBER:
				context.getCounter(MONTH.DEC).increment(10);
				break;
			case Calendar.JANUARY:
				context.getCounter(MONTH.JAN).increment(20);
				break;
			case Calendar.FEBRUARY:
				context.getCounter(MONTH.FEB).increment(30);
				break;
			case Calendar.MARCH:
				context.getCounter(MONTH.MAR).increment(40);
				break;
			case Calendar.APRIL:
				context.getCounter(MONTH.APR).increment(50);
				break;
			case Calendar.MAY:
				context.getCounter(MONTH.MAY).increment(60);
				break;
			case Calendar.JUNE:
				context.getCounter(MONTH.JUN).increment(10);
				break;
			case Calendar.JULY:
				context.getCounter(MONTH.JUL).increment(20);
				break;
			case Calendar.AUGUST:
				context.getCounter(MONTH.AUG).increment(30);
				break;
			case Calendar.SEPTEMBER:
				context.getCounter(MONTH.SEP).increment(40);
				break;
			case Calendar.OCTOBER:
				context.getCounter(MONTH.OCT).increment(50);
				break;
			case Calendar.NOVEMBER:
				context.getCounter(MONTH.NOV).increment(60);
				break;
			default:
				context.getCounter(MONTH.NOV).increment(15);
				break;
			}
			// Give a sleep so that we can print at console
			Thread.sleep(3000);

			out.set("success");
			context.write(out, out);
		}
	}

	public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

		if (args.length != 2) {
			System.err.println("Usage: <input path> <output path>");
			System.exit(1);
		}
		Configuration conf = new Configuration();
		Job job = Job.getInstance(conf);
		job.setJarByClass(com.practice.bigdata.hadoop.mapreduce.advance.counter.CustomMapJobCounter.class);
		job.setJobName("custom_counter");
		job.setNumReduceTasks(0);
		job.setMapperClass(com.practice.bigdata.hadoop.mapreduce.advance.counter.CustomMapJobCounter.Map.class);
		job.setMapOutputKeyClass(Text.class);
		job.setMapOutputValueClass(Text.class);

		Path input = new Path(args[0]);
		Path output = new Path(args[1]);

		FileInputFormat.addInputPath(job, input);
		FileOutputFormat.setOutputPath(job, output);

		FileSystem.get(conf).delete(output, true);

		new Thread(new Runnable() {
			public void run() {
				boolean isRunning = true;
				int jobState = 0;
				while (isRunning) {
					System.out.println("isRunning:" + isRunning);
					// Wrap the whole code in exception
					try {
						jobState = job.getJobState().getValue();
						System.out.println("jobState:" + jobState);
						// stop the loop
						if (jobState == JobStatus.State.SUCCEEDED.getValue()
								|| jobState == JobStatus.State.FAILED.getValue()
								|| jobState == JobStatus.State.KILLED.getValue()) {
							isRunning = false;
						}
						if (jobState == JobStatus.State.RUNNING.getValue()) {
							Counters counters = job.getCounters();
							Counter c1 = null;
							for (MONTH month : MONTH.values()) {
								c1 = counters.findCounter(month);
								System.out.println(c1.getDisplayName() + " : " + c1.getValue());
							}
						}
					} catch (IOException | InterruptedException exe) {
						System.err.println(exe);
					}
				}

			}
		}).start();

		// Wait for the completion - Print the Progress - Pass true
		// System.exit(job.waitForCompletion(true) ? 0 : 1);
		boolean status = job.waitForCompletion(true);

		Counters counters = job.getCounters();

		Counter c1 = null;
		for (MONTH month : MONTH.values()) {
			c1 = counters.findCounter(month);
			System.out.println(c1.getDisplayName() + " : " + c1.getValue());
		}
		System.exit(status ? 0 : 1);

	}

}
