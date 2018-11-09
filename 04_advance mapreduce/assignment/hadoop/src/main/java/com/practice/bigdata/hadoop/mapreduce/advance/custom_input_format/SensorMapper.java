package com.practice.bigdata.hadoop.mapreduce.advance.custom_input_format;

import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class SensorMapper extends Mapper<SensorKey, SensorValue, Text, Text> {

	@Override
	protected void map(SensorKey key, SensorValue value, Mapper<SensorKey, SensorValue, Text, Text>.Context context)
			throws IOException, InterruptedException {
		
		String sensor = key.getSensorType().toString();
		/*
		 * Write Value of Sensor Type a only 
		 */
		if (sensor.toLowerCase().equals("a")) {
			context.write(value.getValue1(), value.getValue2());
		}
	}

}
