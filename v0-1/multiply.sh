#!/bin/bash

infile1="test1"
infile2="test2_transposed"
outfile="mulresults"

file1_rowCount=4
file1_colCount=3
file2_rowCount=3
file2_colCount=4

file2_transposed="tmp_mul1_$$"
tmp_m1_row="tmp_mul2_$$"
tmp_m2_row="tmp_mul3_$$"
tmp_results="tmp_mul4_$$"

#cat $infile2

#transposing second matrix, so can work row-wise on both matrices
for (( i=1; i<"$file2_colCount";i=i+1))
do
    #takes single column from input, tranposes and sends to output
    cut -f $i $infile2 | tr '\n' '\t' >> $file2_transposed    
    echo -e "" >> $file2_transposed         #echo empty string adds end of line
done	


for (( i="$file1_rowCount"; i>0;i=i-1)) 
do  
    #get single row, store in temp file
    cat $infile1 | tail -n $i | head -n 1 > $tmp_m1_row
    cat $file2_transposed | tail -n $i | head -n 1 > $tmp_m2_row

    accum=0 #accumulate row multiplication sum

    for (( j=1; j <= $file1_colCount;j=j+1)) 
    do
        #extract jth element of row into e1, e2
        e1=$(cut -f $j $tmp_m1_row)
        e2=$(cut -f $j $tmp_m2_row)

        #tmp3 containing current summed row elements separated by '\n'
        accum=$(( $accum + ($e1 * $e2) ))
    done

	# contains final result matrix	
    echo $accum | tr '\n' '\t' >> $tmp_results

done

cat $tmp_results
echo ""
rm -f $file2_transposed $tmp_m1_row $tmp_m2_row $tmp_results
 
