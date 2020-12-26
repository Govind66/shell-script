#!/bin/bash

usage="Usage:bash SCRIPT_PATH blksize percentage \\n"

if (( $# != 2 )); then

echo -e $usage

echo -n "Enter block size(Example: 128 or 256 - Default is 256) ->"

read blksize

echo -n "Enter percentage (default:70) ->"

read percentage

else

blksize="$1"

percentage="$2"

fi

echo "assigning blocksize in bytes"

if [ $blksize == 128 ]

then

blk=134217728

elif [ $blksize == 256 ]

then

blk=268435456

else

blk=`echo $blksize*1024*1024 | bc -l`

fi

percentage=`echo "scale=2;$percentage/100" | bc -l`

echo "The given block size is :"

echo $blk

echo "Entered percentage is:" $percentage

echo "--------------------fetching

fsimage-------------------------"

env HADOOP_OPTS="-Xmx16g" hdfs dfsadmin -fetchImage fsimg

echo "--------------------Converting fsimage into readable format------------------"

env HADOOP_OPTS="-Xmx16g" hdfs oiv -i fsimg -o fsout -p Delimited

echo "-------------------------Filtering files taking less than given % of hdfs blocksize---------------"

cat fsout | awk -F:: '{if($7 < ('$blk'*'$percentage')) {print $0}}' > result

echo "------------------sorting and printing small files count-------------------"

cat result | cut -f1 | cut -f1,2,3,4 -d'/'| sort | uniq -c | sort -n | tail -n 20
