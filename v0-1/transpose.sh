#!/bin/bash

infile="test1"
rowSize=4
colSize=3

while read row
do
	for (( i=1; i<"$colSize";i=i+1))
	do
		cut -f $i $row 
	done	
		


done < $infile
