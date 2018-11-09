package com.practice.bigdata.hadoop.projects.country;

import java.util.Objects;

import org.apache.hadoop.hive.ql.exec.UDF;
import org.apache.hadoop.io.Text;

public class LandMass extends UDF {

	public Text evaluate(final Text input) {

		if (Objects.isNull(input)) {
			return null;
		}
		Text text = new Text();
		int i = Integer.parseInt(input.toString());

		switch (i) {
		case 1:
			text.set("N.America");
			break;
		case 2:
			text.set("S.America");
			break;
		case 3:
			text.set("Europe");
			break;
		case 4:
			text.set("Africa");
			break;
		case 5:
			text.set("Asia");
			break;
		case 6:
			text.set("Oceania");
			break;
		default:
			break;
		}
		return text;
	}
}
