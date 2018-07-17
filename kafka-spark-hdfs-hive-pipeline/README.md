# Kafka-Spark-Hdfs-Hive Pipeline
This is a simple pipeline application with kafka producer to get raw tweet data(json) from twitter. Then Spark Streaming will be used to extract required schema from the tweet data and dump the schema-oriented data to hdfs (`/user/hive/twitter` path location in hdfs). After this, one will create hive external table pointing to /user/hive/twitter path in hdfs. Then one can do hive query on tweet data.

#### Note: Make sure, user running the apps has access to hdfs(`/user/hive/twitter`).

## Getting Started

These instructions will get you running this application on **InstantBigData** environment.

### Installing

A step by step series to install the pipeline:

* Go to the kafka source directory.

* Clone the **InstantBigData** repository:

```bash
git clone https://github.com/DCEngines/InstantBigData.git
```

* Go to the directory InstantBigData/kafka-spark-hdfs-hive-pipeline:

* Install required to run kafka twitter producer:

```bash
pip install -r requirements.txt
```

* Add your twitter app credentials and kafka broker list in twitter_app_credentials.txt.

* Open new terminal and go to spark source directory:

* If kafka client jar is not there in spark jars directory, download and put in the jars directory in spark source directory. 

* Download the spark sql jar for kafka according to the spark version. For example, with spark 2.3.0 and scala 2.11, jar name is `spark-sql-kafka-0-10_2.11-2.3.0.jar`

Above steps will setup and configure the pipeline.

## Running the App

* Go to kafka terminal , run below command:

```bash
python twitter_producer.py
```
It will get the twitter data and put in `twitterstream` topic in kafka.

* Go to spark terminal, run below command

```bash
bin/spark-shell  --master [ spark://<ip>:7077 | yarn] --packages <spark-sql-kafka-package>
```
For example, with jar `spark-sql-kafka-0-10_2.11-2.3.0.jar`, package name is `org.apache.spark:spark-sql-kafka-0-10_2.11:2.3.0`

* Set `<kafka-broker>` and `<hdfs-url>` in below code and copy the below code and run on the spark-shell.
 ```sh
import org.apache.spark.sql.SparkSession
import spark.implicits._
import org.apache.spark.sql.functions.from_json
import org.apache.spark.sql.types._
val spark = SparkSession.builder.appName("twitter-spark-stream").getOrCreate()
val schema = StructType(Seq(StructField("created_at", StringType, true),StructField("id_str", StringType, true),StructField("text", StringType, true),StructField("source",StringType, true),StructField("truncated", BooleanType, true),StructField("in_reply_to_status_id_str", StringType, true),StructField("in_reply_to_user_id_str", StringType, true),StructField("in_reply_to_screen_name", StringType, true),StructField("user", StructType(Seq(StructField("id_str", StringType, true),StructField("name", StringType, true),StructField("screen_name", StringType, true),StructField("location", StringType, true),StructField("url", StringType, true),StructField("description", StringType, true),StructField("translator_type", StringType, true),StructField("protected", BooleanType, true),StructField("verified", BooleanType, true),StructField("followers_count", IntegerType, true),StructField("friends_count", IntegerType, true),StructField("listed_count", IntegerType, true),StructField("favourites_count", IntegerType, true),StructField("created_at", StringType, true),StructField("utc_offset", IntegerType, true),StructField("time_zone", StringType, true),StructField("geo_enabled", BooleanType, true),StructField("lang", StringType, true))), true),StructField("geo", StringType, true),StructField("place",  StructType(Seq(StructField("id", StringType, true),StructField("url", StringType, true),StructField("place_type", StringType, true),StructField("name", StringType, true),StructField("full_name", StringType, true),StructField("country_code", StringType, true),StructField("country", StringType, true))), true),StructField("reply_count", IntegerType, true),StructField("retweet_count", IntegerType, true),StructField("favorite_count", IntegerType, true),StructField("timestamp_ms", StringType, true)))
val BOOTSTRAP_SERVER = <kafka-broker> // for example: "ag1.ibd:6667"
val TOPIC = "twitterstream"
val lines = spark.readStream.format("kafka").option("kafka.bootstrap.servers", BOOTSTRAP_SERVER).option("subscribe", TOPIC).load().select(from_json($"value".cast("string"), schema).as("data")).select("data.*")

import scala.util.parsing.json._

val HDFS_URL = <hdfs-url>  // for example:"hdfs://ag1.ibd:8020"

val query = lines.writeStream.option("path", HDFS_URL + "/user/hive/twitter").option("checkpointLocation", "/CheckPoint/").outputMode("append").format("json").start()

query.awaitTermination()
```

* When you think enough data is being push to hdfs(dir - `/user/hive/twitter`), stop the Kafka twitter_producer.py and spark shell (using ctrl-C or ^C).

* Go to hive shell (run `hive` cmd to go to the hive shell) and run below code. This creates `twitterdb` database and `tweets` table inside hive.
```sh
CREATE DATABASE TwitterDB;
USE TwitterDB;
CREATE EXTERNAL TABLE tweets (
    created_at STRING,    
    id_str STRING,
    text STRING,
    source STRING,
    truncated BOOLEAN,
    in_reply_to_status_id_str STRING,
    in_reply_to_user_id_str STRING,
    in_reply_to_screen_name STRING,
    `user` STRUCT<
     id_str:STRING,
     name:STRING,
     screen_name:STRING,
     location:STRING,
     url:STRING,
     description:STRING,
     translator_type:STRING,
     protected:BOOLEAN,
     verified:BOOLEAN,
     followers_count:INT,
     friends_count:INT,
     listed_count:INT,
     favourites_count:INT,
     created_at:STRING,
     utc_offset:INT,
     time_zone:STRING,
     geo_enabled:BOOLEAN,
     lang:STRING>,
    geo STRING,
    place STRUCT<
     id:STRING,
     url:STRING,
     place_type:STRING,
     name:STRING,
     full_name:STRING,
     country_code:STRING,
     country:STRING>,
    reply_count INT,
    retweet_count INT,
    favorite_count INT,
    timestamp_ms STRING
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE LOCATION '/user/hive/twitter';
```

Now you can run any hive query on tweets. There are few query one can run.

* On hive shell, check columns of `tweets` table in `twitterdb` database:
```sh
DESC tweets;
```

* On hive shell, lets check name of user, text and country of the tweets including 'trump' word:
```sh
SELECT `user`.name, text, place.country FROM tweets WHERE text like "%trump%";
```

* On hive shell, check no. of records in tweets table;
```sh
select count(*) as tweet_count from tweets;
```
