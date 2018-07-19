# An Hadoop MapReduce Program In Python

In this example, we run a simple MapReduce program for Hadoop in the Python programming language.

##### Note: This example is referred fomr this [post](https://www.michael-noll.com/tutorials/writing-an-hadoop-mapreduce-program-in-python/)

## Steps

* Go to hadoop container where mapreduce jars are available.

* Clone the **InstantBigData** repository.
```sh
git clone https://github.com/DCEngines/InstantBigData.git
``` 

* Go to directory `InstantBigData/mapreduce_wordcount/`.

* Copy the `gutenberg` directory to hdfs, lets take `/user/root` as hdfs directory where we will put the `gutenberg` data.
```sh
hdfs dfs -copyFromLocal gutenberg /user/root/
```
* run below command with required arguments.
```sh
hadoop jar <path-to-hadoop-streaming.jar> -file ./mapper.py -mapper ./mapper.py -file ./reducer.py -reducer ./reducer.py -input /user/root/gutenberg/* -output /user/root/gutenberg-output
```
Make sure `hadoop` command is available at shell. If not write the full path to hadoop command in above command. And hadoop streaming jar is available in hadoop directory.

* Above command will generate output directory `/user/root/gutenberg-output` with output file. One check the output with below command.
```sh
hdfs dfs -cat /user/root/gutenberg-output/part-0000
```

It will show each line container a word with its count.

