#!/bin/bash

#global variables
infile1="tmp_infile_$$" #need temp for input 1 if matrix piped in
infile2=""
outfile=""

file1_rowCount=0
file1_colCount=0
file2_rowCount=0
file2_colCount=0

countDimensionsM1(){
    while read row
    do
        count=0
        for i in $row
        do
            ((count++))
        done

        #set column size using first row, verify other rows are same 	
        if [ "$file1_rowCount" -eq 0 ]
        then
            #echo "first row"
            file1_colCount="$count"
        else
            if [ "$count" -ne "$file1_colCount" ]
            then
                echo "ERROR -- matrix not complete"
		exit 1
            fi
        fi
        
        ((file1_rowCount++))

    done < $infile1
}

countDimensionsM2(){

    while read row
    do
        count=0
        for i in $row
        do
            ((count++))
        done

        #set column size using first row, verify other rows are same 	
        if [ "$file2_rowCount" -eq 0 ]
        then
            #echo "first row"
            file2_colCount="$count"
        else
            if [ "$count" -ne "$file2_colCount" ]
            then
                echo "ERROR -- matrix not complete"
        exit 1
            fi
        fi
        
        ((file2_rowCount++))

    done < $infile2


    return
}



multiply(){

#calculates dimension of both matrices, sets global variables
countDimensionsM1
countDimensionsM2

echo "row and column counts: $file1_rowCount $file1_colCount $file2_rowCount $file2_colCount"


file2_transposed="tmp_mul1_$$"
tmp_m1_row="tmp_mul2_$$"
tmp_m2_row="tmp_mul3_$$"
tmp_results_row="tmp_mul4_$$"

#cat $infile1
#cat $infile2

#echo "file2_colCount $file2_colCount"
#transposing second matrix, so can work row-wise on both matrices

for (( i=1; i<="$file2_colCount";i=i+1))
do
    #takes single column from input, tranposes
    tmp_row="$(cut -f $i $infile2 | tr '\n' '\t')"
    echo "${tmp_row%?}" >> $file2_transposed
done

#cat $file2_transposed

for (( i="$file1_rowCount"; i>0;i=i-1)) 
do  
    #get single row first matrix, store in temp file
    cat $infile1 | tail -n $i | head -n 1 > $tmp_m1_row

    for (( k="$file1_rowCount"; k>0;k=k-1)) 
    do 
        #single row second matrix
        cat $file2_transposed | tail -n $k | head -n 1 > $tmp_m2_row

        accum=0 #accumulate row multiplication sum

        for (( j=1; j <= $file1_colCount;j=j+1)) 
        do
            #extract jth element of row into e1, e2
            e1=$(cut -f $j $tmp_m1_row)
            e2=$(cut -f $j $tmp_m2_row)

            #tmp3 containing current summed row elements separated by '\n'
            accum=$(( $accum + ($e1 * $e2) ))
        done

        echo "element $i $k: $accum"
        # write single element to current result row
        echo $accum | tr '\n' '\t' >> $tmp_results_row
        
    done

    #start new results row
    echo "" >> $tmp_results_row

done

cat -A $tmp_results_row

rm -f $file2_transposed $tmp_m1_row $tmp_m2_row $tmp_results

return
}


    infile1=$2
    infile2=$3
    #echo "case number 2 -- two parameter functions"

    #run function
    $1
