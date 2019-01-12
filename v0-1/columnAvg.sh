#!/bin/bash

infile="test1"
tempTransposed="tmp_avg1_$$"
tempResults="tmp_avg2_$$"
rowSize=4
colSize=3


#step 1: transpose matrix, so can average rows
for (( i=1; i<="$colSize";i=i+1))
do
    #takes single column from input, tranposes and sends to output
    cut -f $i $infile | tr '\n' '\t' >> $tempTransposed   
    echo -e "" >> $tempTransposed          #echo empty string adds end of line
done	

#step 2: loop over rows, calculate average of each row
while read row
do
	sum=0
	for i in $row
	do
		sum=$(( $sum + $i ))
	done
    # average = sum / (input rowsize)
	echo -e "row: $row"
	echo -e "sum: $sum"
    expr $(( (( $sum + (( $rowSize / 2)) * (( ($sum>0) * 2 - 1)) )) / $rowSize )) >> $tempResults
done < $tempTransposed

#print results
cat $tempResults

#cleanup
#rm $tempTransposed $tempResults
