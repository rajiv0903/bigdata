"""
 Launch Python Spark Shell : pyspark
 spark-sql
"""
myfile = sc.textFile("hdfs://ip-20-0-21-161.ec2.internal:8020/user/edureka_424232/spark_filesystem/wordcount/python/input_small/wordcountproblem_small");
counts = myfile.flatMap(lambda line: line.split(" ")).map(lambda word: (word,1)).reduceByKey(lambda v1,v2: v1 + v2);

counts.saveAsTextFile("hdfs://ip-20-0-21-161.ec2.internal:8020/user/edureka_424232/spark_filesystem/wordcount/python/output/wordcountproblem_small");
