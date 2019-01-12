#!/bin/bash

infile1="test1"
infile2="test2"
outfile="addresults"
rowCount=4
colCount=3


for (( i="$rowCount"; i>0;i=i-1)) 
do  
    #get row number (rowcount - i) from file1, file2 -- (accessing from bottom)
    r1="$( cat $infile1 | tail -n $i | head -n 1)"
    r2="$( cat $infile2 | tail -n $i | head -n 1)"

	echo -e "r1: $r1"
	echo -e "r2: $r2"


    for (( j=1; j <= $colCount;j=j+1)) 
    do
        #get the jth element from rows r1, r2
        #e1="$( cut -f $j $r1 )"
        #e2="$( cut -f $j $r2 )"
        #echo "e1:$e1 e2:$e2" 
        
	cut -f $j $r1
        cut -f $j $r2

        # outputf
        #cat $( $e1 + $e2 ) 
    done

done
