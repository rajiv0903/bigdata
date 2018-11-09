package com.practice.bigdata.hadoop.mapreduce.advance.custom_input_format;

import java.io.IOException;

import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;

public class SensorInputFormat extends FileInputFormat<SensorKey, SensorValue>{

	@Override
	public RecordReader<SensorKey, SensorValue> createRecordReader(InputSplit split, TaskAttemptContext context)
			throws IOException, InterruptedException {
		return new SensorRecordReader();
	}

}
