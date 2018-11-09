package com.practice.bigdata.hadoop.mapreduce.advance.partitioner;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Partitioner;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class DepartmentMaxSalaryHolders extends Configured implements Tool {

	static class MapPartitioner extends Mapper<LongWritable, Text, Text, Text> {

		@Override
		protected void map(LongWritable key, Text value, Mapper<LongWritable, Text, Text, Text>.Context context)
				throws IOException, InterruptedException {

			String[] tokens = value.toString().split(",");
			String emp_dept = tokens[2].toString();
			String emp_id_n_ds_sal = tokens[0] + "," + tokens[1] + "," + tokens[3] + "," + tokens[4] + "," + tokens[5];
			//Key is Department send to Partitioner
			context.write(new Text(emp_dept), new Text(emp_id_n_ds_sal));
		}
	}

	static class DeptPartitioner extends Partitioner<Text, Text> {

		@Override
		public int getPartition(Text key, Text value, int numReduceTasks) {
			/*
			 * Key is Department name which will decide to where to send the reducer
			 * So that at reducer we will get data for that department only : To apply logic
			 * for max salary of that department
			 */
			if (numReduceTasks == 0)
				return 0;
			if (key.equals(new Text("Dept 1"))) {
				return 0;
			} else if (key.equals(new Text("Dept 2"))) {
				return 1 % numReduceTasks;
			} else
				return 2 % numReduceTasks;
		}
	}

	static class ReduceParitioner extends Reducer<Text, Text, Text, Text> {

		@Override
		protected void reduce(Text key, Iterable<Text> values, Reducer<Text, Text, Text, Text>.Context context)
				throws IOException, InterruptedException {

			int max_sal = Integer.MIN_VALUE;
			String emp_name = "", emp_dept = "", emp_des = "", emp_id = "";
			int emp_sal = 0;

			/*
			 * Partitioner makes sure that we got the data of that Department only
			 */
			for (Text val : values) {
				String[] valTokens = val.toString().split(",");
				emp_sal = Integer.parseInt(valTokens[3]);
				if (emp_sal > max_sal) {

					emp_id = valTokens[0];
					emp_name = valTokens[1];
					emp_des = valTokens[2];
					emp_dept = key.toString();
					max_sal = emp_sal;
				}
			}
			context.write(new Text(emp_dept),
					new Text("id=>" + emp_id + ",name=>" + emp_name + ",des=>" + emp_des + ",sal=>" + max_sal));
		}
	}

	@Override
	public int run(String[] args) throws Exception {
		if (args.length != 2) {
			System.out.println("Usage: <input file path> <output file path>");
			return 1;
		}
		// Getting configuration object and setting job name
		Configuration conf = getConf();
		Job job = Job.getInstance(conf, "Dept_Max_Salary");

		// setting the class names
		job.setJarByClass(DepartmentMaxSalaryHolders.class);
		job.setMapperClass(MapPartitioner.class);
		job.setPartitionerClass(DeptPartitioner.class);
		job.setReducerClass(ReduceParitioner.class);

		// Force to run the reducer
		job.setNumReduceTasks(3);

		job.setInputFormatClass(TextInputFormat.class);
		job.setOutputFormatClass(TextOutputFormat.class);

		// setting the output data type classes
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);

		// To accept the hdfs input and outpur dir at run time
		FileInputFormat.addInputPath(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));

		return job.waitForCompletion(true) ? 0 : 1;
	}

	public static void main(String[] args) throws Exception {

		int res = ToolRunner.run(new Configuration(), new DepartmentMaxSalaryHolders(), args);
		System.exit(res);

	}

}
