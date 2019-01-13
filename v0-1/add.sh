#!/bin/bash

infile1="test1"
infile2="test2"
outfile="addresults"
rowCount=4
colCount=3

tmp1="tmp_add1_$$"
tmp2="tmp_add2_$$"
tmp3="tmp_add3_$$"
tmp4="tmp_add4_$$"

for (( i="$rowCount"; i>0;i=i-1)) 
do  
    #get single row, store in temp file
    cat $infile1 | tail -n $i | head -n 1 > $tmp1
    cat $infile2 | tail -n $i | head -n 1 > $tmp2

    for (( j=1; j <= $colCount;j=j+1)) 
    do
        #extract jth element of row into e1, e2
        e1=$(cut -f $j $tmp1)
        e2=$(cut -f $j $tmp2)

        #tmp3 containing current summed row elements separated by '\n'
        expr $e1 + $e2  >> $tmp3
    done

	#tmp4 contains final result matrix	
    cat $tmp3 | tr '\n' '\t' >> $tmp4
    rm $tmp3

    echo "" >> $tmp4
	 
done

cat $tmp4

rm $tmp1 $tmp2 $tmp4