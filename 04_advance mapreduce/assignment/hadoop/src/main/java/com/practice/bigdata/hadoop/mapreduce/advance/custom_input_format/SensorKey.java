package com.practice.bigdata.hadoop.mapreduce.advance.custom_input_format;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.WritableComparable;

public class SensorKey implements WritableComparable<SensorKey> {

	private Text sensorType, timestamp, status;

	/*
	 * Initialize the custom key fields
	 */
	public SensorKey() {
		this.sensorType = new Text();
		this.timestamp = new Text();
		this.status = new Text();
	}

	public SensorKey(Text sensorType, Text timestamp, Text status) {
		this.sensorType = new Text();
		this.timestamp = new Text();
		this.status = new Text();
	}

	@Override
	public void write(DataOutput out) throws IOException {
		this.sensorType.write(out);
		this.timestamp.write(out);
		this.status.write(out);
	}

	@Override
	public void readFields(DataInput in) throws IOException {
		this.sensorType.readFields(in);
		this.timestamp.readFields(in);
		this.status.readFields(in);
	}

	@Override
	public int compareTo(SensorKey o) {
		
		SensorKey other = (SensorKey) o;
		int cmp = this.sensorType.compareTo(other.sensorType);
		if (cmp != 0) {
			return cmp;
		}
		cmp = this.timestamp.compareTo(other.timestamp);
		if (cmp != 0) {
			return cmp;
		}
		return this.status.compareTo(other.status);
	}

	public Text getSensorType() {
		return sensorType;
	}

	public void setSensorType(Text sensorType) {
		this.sensorType = sensorType;
	}

	public Text getTimestamp() {
		return timestamp;
	}

	public void setTimestamp(Text timestamp) {
		this.timestamp = timestamp;
	}

	public Text getStatus() {
		return status;
	}

	public void setStatus(Text status) {
		this.status = status;
	}
	
	

}
