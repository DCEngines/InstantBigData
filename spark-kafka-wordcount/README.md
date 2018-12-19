# Structured Spark Streaming Kafka WordCount Example

This example consumes messages from one or more topics in Kafka and does word count. Following is the usage of word count example.

```bash
StructuredKafkaWordCount <bootstrap-servers> <subscribe-type> <topics>
```

## Getting Started

These instructions will get you running this application on **InstantBigData** environment.


### Steps

* Go into the Kafka container.

* Go the Kafka directory

* Create a Kafka topic, let's say "test":

```bash
bin/kafka-topics.sh --create --zookeeper <zookeeper> --replication-factor 1 --partitions 1 --topic test
```

* Start a console producer. Input from the console is send to the Kafka partition:

```bash
bin/kafka-console-producer.sh --broker-list <broker-list> --topic test
```
Leave this terminal as it is.

* Start another terminal and go into the Spark container.

* Go to spark directory

* Download the spark sql kafka jar .For example, with spark 2.3.0 and scala 2.11, jar name is spark-sql-kafka-0-10_2.11-2.3.0.jar

* If kafka client jar is not there in spark jars directory, download and put in the jars directory in spark source directory.

* Submit the spark example that counts the word published by the console producer. The code for this application can be found [HERE](https://github.com/apache/spark/blob/branch-2.3/examples/src/main/scala/org/apache/spark/examples/sql/streaming/StructuredKafkaWordCount.scala):
```bash
bin/spark-submit  --master [ spark://<ip>:7077 | yarn]  --jars <path-to-spark-sql-kafka-jar>  --packages <groupId:artifactId:version>  --class org.apache.spark.examples.sql.streaming.StructuredKafkaWordCount   <path-to-spark-examples-jar>  <kafka-broker> subscribe  test
```

For Example, for hdp 
```bash
bin/spark-submit  --master yarn  --jars ./spark-sql-kafka-0-10_2.11-2.3.0.jar  --packages org.apache.spark:spark-sql-kafka-0-10_2.11:2.3.0  --class org.apache.spark.examples.sql.streaming.StructuredKafkaWordCount   ./examples/jars/spark-examples_2.11-2.3.0.2.6.5.0-292.jar  <kafka-broker> subscribe  test
```

* Go back to Kafka container terminal, input some words on the console producer. And one will see the word count for each words in spark container terminal.


