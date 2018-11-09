/**
* Launch Scala Spark Shell : spark-shell
*/
/**
 * Create the RDD from Text file- Lazy Load
 */

val inputfile = sc.textFile("spark/artifacts/wordcountproblem_small");

/**
 * What is the content 
 */
inputfile.collect;

val counts = inputfile.flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_+_);
counts.collect;
counts.saveAsTextFile("spark/artifacts/wordcountproblem_small_output");