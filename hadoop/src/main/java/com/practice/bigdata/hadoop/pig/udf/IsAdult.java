package com.practice.bigdata.hadoop.pig.udf;

import java.io.IOException;

import org.apache.pig.FilterFunc;
import org.apache.pig.backend.executionengine.ExecException;
import org.apache.pig.data.Tuple;

public class IsAdult extends FilterFunc {

	@Override
	public Boolean exec(Tuple input) throws IOException {

		if (input == null || input.size() == 0) {
			return null;
		}
		try {
			Object object = input.get(0);
			if (object == null) {
				return false;
			}
			int i = (Integer) object;
			if (i == 23 || i == 21 || i == 27) {
				return true;
			}
			return false;
			
		} catch (ExecException exe) {
			System.err.println(exe);
		}
		return null;
	}

}
