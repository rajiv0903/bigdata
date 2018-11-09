package com.practice.bigdata.hadoop.mapreduce.advance.distributed_cache;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class StatePopulation {

	public static class StatePopulationMapper extends Mapper<LongWritable, Text, Text, Text> {

		private Map<String, String> abMap = new HashMap<String, String>();
		private Text outputKey = new Text();
		private Text outputValue = new Text();

		protected void setup(Context context) throws java.io.IOException, InterruptedException {

			super.setup(context);

			URI[] files = context.getCacheFiles(); // getCacheFiles returns null

			for (URI uri : files) {
				// System.out.println("uri: <uri, uri path>: <" +uri.toString()+","+
				// uri.getPath()+">");
				Path p = new Path(uri);
				if (p.getName().equals("state_lookup.dat")) {
					FileSystem fs = FileSystem.get(context.getConfiguration());
					BufferedReader reader = new BufferedReader(new InputStreamReader(fs.open(p)));
					try {
						String line = reader.readLine();
						while (line != null) {
							System.out.println(line);
							String[] tokens = line.split("\t");
							String ab = tokens[0];
							String state = tokens[1];
							abMap.put(ab, state);
							line = reader.readLine();
						}
					} finally {
						reader.close();
					}
				}
			}
			if (abMap.isEmpty()) {
				throw new IOException("Unable to load Abbrevation data.");
			}
			// System.out.println("Map:"+ abMap);
		}

		protected void map(LongWritable key, Text value, Context context)
				throws java.io.IOException, InterruptedException {

			String row = value.toString();
			String[] tokens = row.split("\t");
			String inab = tokens[0];
			String state = abMap.get(inab);
			outputKey.set(state);
			outputValue.set(row);
			context.write(outputKey, outputValue);
		}
	}

	public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

		if (args == null || args.length != 3) {
			System.err.println("Usage: <input directory> <output directory> <cache file path>");
			System.exit(1);
		}
		Configuration conf = new Configuration();
		Job job = Job.getInstance(conf, "state_population");
		job.setJarByClass(com.practice.bigdata.hadoop.mapreduce.advance.distributed_cache.StatePopulation.class);
		job.setNumReduceTasks(0);
		job.setMapperClass(
				com.practice.bigdata.hadoop.mapreduce.advance.distributed_cache.StatePopulation.StatePopulationMapper.class);
		job.setMapOutputKeyClass(Text.class);
		job.setMapOutputValueClass(Text.class);

		Path input = new Path(args[0]);
		Path output = new Path(args[1]);
		Path cacheFile = new Path(args[2]);

		job.addCacheFile(cacheFile.toUri());

		FileInputFormat.addInputPath(job, input);
		FileOutputFormat.setOutputPath(job, output);

		FileSystem.get(conf).delete(output, true);

		System.exit(job.waitForCompletion(true)? 0: 1);

	}
}