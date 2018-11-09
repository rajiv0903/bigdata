package com.practice.bigdata.hadoop.hive.advance.udf;

import java.util.Objects;

import org.apache.hadoop.hive.ql.exec.UDF;
import org.apache.hadoop.io.Text;

public class Capitalize extends UDF {

	public Text evaluate(final Text input) {

		if (Objects.isNull(input)) {
			return null;
		}
		return new Text(input.toString().toUpperCase().charAt(0) + input.toString().substring(1));
	}
}
