#!/bin/bash

file="vector-8.csv"
wanted_size=2000000 #2MB
b_check=20 #how many lines to write before checking file size
actual_size=0

true > $file #delete file contents
while [ $actual_size -lt $wanted_size ]; do
    for ((i = 0 ; i < $b_check ; i++)); do
        echo "$RANDOM,$RANDOM,$RANDOM,$RANDOM,$RANDOM,$RANDOM,$RANDOM,$RANDOM" >> $file
    done
	actual_size=$(wc -c <"$file") #file size in bytes
done
