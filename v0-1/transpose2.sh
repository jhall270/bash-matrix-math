#!/bin/bash

infile="test1"
outfile="transposed_result"
rowSize=4
colSize=3


for (( i=1; i<"$colSize";i=i+1))
do
    #takes single column from input, tranposes and sends to output
    cut -f $i $infile | tr '\n' '\t' >> $outfile    
    echo -e "" >> $outfile          #echo empty string adds end of line
done	

