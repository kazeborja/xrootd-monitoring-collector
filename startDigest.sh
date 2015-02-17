#!/usr/bin/env bash

DateToProcess=$(date --date="1 days ago" +%Y-%m-%d)

echo "Processing... "${DateToProcess}

echo "Cleaning new data."
pig -f cleaner.pig -param INPF=${DateToProcess} 

echo "Grouping ... "

if hdfs dfs -test -d Summary/Maxis ; then
    echo "Maxis directory exists"
else
    hdfs dfs -mkdir Summary/Maxis
    echo "Creating Maxis directory"
fi

pig -f grouper.pig -param INPF=${DateToProcess} 

echo "removing old last values."
hdfs dfs -rm -R /user/ivukotic/Summary/MaxisOLD

echo "moving current last values to OLD."
hdfs dfs -mv '/user/ivukotic/Summary/Maxis' '/user/ivukotic/Summary/MaxisOLD';

echo "moving new last values to current."
hdfs dfs -mv '/user/ivukotic/Summary/MaxisNEW' '/user/ivukotic/Summary/Maxis';
