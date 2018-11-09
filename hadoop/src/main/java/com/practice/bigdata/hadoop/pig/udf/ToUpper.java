package com.practice.bigdata.hadoop.pig.udf;

import java.io.IOException;

import org.apache.pig.EvalFunc;
import org.apache.pig.backend.executionengine.ExecException;
import org.apache.pig.data.Tuple;

public class ToUpper extends EvalFunc<String> {

	@Override
	public String exec(Tuple input) throws IOException {

		if (input == null || input.size() == 0) {
			return null;
		}
		try {
			String str = (String) input.get(0);
			return str.toUpperCase();

		} catch (ExecException e) {
			System.err.println(e);
		}
		return null;
	}

}
