"""
 Launch Python Spark Shell : pyspark
 spark-sql
"""
myfile = sc.textFile("hdfs://nameservice1:8020/spark_filesystem/wordcount/python/input/wordcountproblem_small");
counts = myfile.flatMap(lambda line: line.split(" ")).map(lambda word: (word,1)).reduceByKey(lambda v1,v2: v1 + v2);
counts.saveAsTextFile("hdfs://nameservice1:8020/spark_filesystem/wordcount/python/output/wordcountproblem_small");