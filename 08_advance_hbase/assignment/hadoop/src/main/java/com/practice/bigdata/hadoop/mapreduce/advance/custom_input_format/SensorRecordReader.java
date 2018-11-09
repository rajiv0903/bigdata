package com.practice.bigdata.hadoop.mapreduce.advance.custom_input_format;

import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.LineRecordReader;

public class SensorRecordReader extends RecordReader<SensorKey, SensorValue> {

	private SensorKey key;
	private SensorValue value;
	private LineRecordReader reader = new LineRecordReader();

	@Override
	public void initialize(InputSplit split, TaskAttemptContext context) throws IOException, InterruptedException {
		this.reader.initialize(split, context);
	}

	@Override
	public boolean nextKeyValue() throws IOException, InterruptedException {

		boolean gotNextKeyValue = this.reader.nextKeyValue();
		if (gotNextKeyValue) {
			if (this.key == null) {
				this.key = new SensorKey();
			}
			if (this.value == null) {
				this.value = new SensorValue();
			}
			Text line = reader.getCurrentValue();
			String[] tokens = line.toString().split("\t");
			this.key.setSensorType(new Text(tokens[0]));
			this.key.setTimestamp(new Text(tokens[1]));
			this.key.setStatus(new Text(tokens[2]));
			this.value.setValue1(new Text(tokens[3]));
			this.value.setValue2(new Text(tokens[4]));
		} else {
			this.key = null;
			this.value = null;
		}
		return gotNextKeyValue;
	}

	@Override
	public SensorKey getCurrentKey() throws IOException, InterruptedException {
		return this.key;
	}

	@Override
	public SensorValue getCurrentValue() throws IOException, InterruptedException {
		return this.value;
	}

	@Override
	public float getProgress() throws IOException, InterruptedException {
		return this.reader.getProgress();
	}

	@Override
	public void close() throws IOException {
		this.reader.close();
	}

}
