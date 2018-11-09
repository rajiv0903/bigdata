package com.practice.bigdata.hadoop.projects.country;

import java.util.Objects;

import org.apache.hadoop.hive.ql.exec.UDF;
import org.apache.hadoop.io.Text;

public class Religion extends UDF {

	public Text evaluate(final Text input) {

		if (Objects.isNull(input)) {
			return null;
		}
		Text text = new Text();
		int i = Integer.parseInt(input.toString());

		switch (i) {
		case 0:
			text.set("Catholic");
			break;
		case 1:
			text.set("Other Christian");
			break;
		case 2:
			text.set("Muslim");
			break;
		case 3:
			text.set("Buddhist");
			break;
		case 4:
			text.set("Hindu");
			break;
		case 5:
			text.set("Ethnic");
			break;
		case 6:
			text.set("Marxist");
			break;
		case 7:
			text.set("Others");
			break;
		default:
			break;
		}
		return text;
	}
}
