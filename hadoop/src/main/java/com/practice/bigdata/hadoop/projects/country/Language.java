package com.practice.bigdata.hadoop.projects.country;

import java.util.Objects;

import org.apache.hadoop.hive.ql.exec.UDF;
import org.apache.hadoop.io.Text;

public class Language extends UDF {

	public Text evaluate(final Text input) {

		if (Objects.isNull(input)) {
			return null;
		}
		Text text = new Text();
		int i = Integer.parseInt(input.toString());

		switch (i) {
		case 1:
			text.set("English");
			break;
		case 2:
			text.set("Spanish");
			break;
		case 3:
			text.set("French");
			break;
		case 4:
			text.set("German");
			break;
		case 5:
			text.set("Slavic");
			break;
		case 6:
			text.set("Other Indo-European");
			break;
		case 7:
			text.set("Chinese");
			break;
		case 8:
			text.set("Arabic");
			break;
		case 9:
			text.set("Japanese/Turkish/Finnish/Magyar");
			break;
		case 10:
			text.set("Others");
			break;
		default:
			break;
		}
		return text;
	}
}
