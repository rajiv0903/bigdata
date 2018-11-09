package com.practice.bigdata.hadoop.mapreduce.advance.custom_input_format;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.WritableComparable;

public class SensorValue implements WritableComparable<SensorValue> {

	private Text value1, value2;

	/*
	 * Initialize fields
	 */
	public SensorValue() {
		this.value1 = new Text();
		this.value2 = new Text();
	}

	public SensorValue(Text value1, Text value2) {
		this.value1 = value1;
		this.value2 = value2;
	}

	@Override
	public void write(DataOutput out) throws IOException {
		this.value1.write(out);
		this.value2.write(out);
	}

	@Override
	public void readFields(DataInput in) throws IOException {
		this.value1.readFields(in);
		this.value2.readFields(in);
	}

	@Override
	public int compareTo(SensorValue o) {
		SensorValue other = (SensorValue) o;
		int cmp = this.value1.compareTo(other.value1);
		if (cmp != 0) {
			return cmp;
		}
		return this.value2.compareTo(other.value2);
	}

	public Text getValue1() {
		return value1;
	}

	public void setValue1(Text value1) {
		this.value1 = value1;
	}

	public Text getValue2() {
		return value2;
	}

	public void setValue2(Text value2) {
		this.value2 = value2;
	}
	
}
