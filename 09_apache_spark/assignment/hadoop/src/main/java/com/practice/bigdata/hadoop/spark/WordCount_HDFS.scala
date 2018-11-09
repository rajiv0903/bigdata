
/**
* Launch Scala Spark Shell : spark-shell
*/
val myfile = sc.textFile("hdfs://nameservice1:8020/spark_filesystem/wordcount/scala/input_small/wordcountproblem_small");
myfile.collect;
val counts = myfile.flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_+_);
counts.collect;
counts.saveAsTextFile("hdfs://nameservice1:8020/spark_filesystem/wordcount/scala/output/wordcountproblem_small");
