
/**
* Launch Scala Spark Shell : spark-shell
*/

val hadoopConf = sc.hadoopConfiguration;
var hdfs = org.apache.hadoop.fs.FileSystem.get(hadoopConf);

val myfile = sc.textFile("hdfs://ip-20-0-21-161.ec2.internal:8020/user/edureka_424232/spark_filesystem/wordcount/scala/input_small/wordcountproblem_small");
myfile.collect;
val counts = myfile.flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_+_);
counts.collect;

  
counts.saveAsTextFile("hdfs://ip-20-0-21-161.ec2.internal:8020/user/edureka_424232/spark_filesystem/wordcount/scala/output/wordcountproblem_small");
