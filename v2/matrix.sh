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


#
dims(){
    #check if file size >0
    if [ -s "$infile1" ]
    then
        countDimensionsM1
    else
        echo "ERROR: empty matrix" >&2  ##sending to standard error
        exit 1 ##error  
    fi



    echo "$file1_rowCount $file1_colCount"
    return
}

transpose(){
    countDimensionsM1
    outfile="tmp_outfile_$$" 

    for (( i=1; i<="$file1_colCount";i=i+1))
    do
        #takes single column from input, tranposes
        tmp_row="$(cut -f $i $infile1 | tr '\n' '\t')"
        echo "${tmp_row%?}" >> $outfile
    done

    cat $outfile
    return
}

mean(){
    countDimensionsM1

    tempTransposed="tmp_avg1_$$"
    tempResults="tmp_avg2_$$"

    #step 1: transpose matrix, so can work with rows instead of columns

    for (( i=1; i<="$file1_colCount";i=i+1))
    do
        #takes single column from input, tranposes
        tmp_row="$(cut -f $i $infile1 | tr '\n' '\t')"
        echo "${tmp_row%?}" >> $tempTransposed 
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
        #echo -e "row: $row"
        #echo -e "sum: $sum"
        expr $(( (( $sum + (( $file1_rowCount / 2)) * (( ($sum>0) * 2 - 1)) )) / $file1_rowCount )) >> $tempResults
    done < $tempTransposed

    #print results, currently in temp file as single column so need to transpose before writing
    result_row="$(cut -f 1 $tempResults | tr '\n' '\t')"
    echo "${result_row%?}" 

    #cleanup
    rm $tempTransposed $tempResults

    return
}

add(){
countDimensionsM1
countDimensionsM2

tmp1="tmp_add1_$$"
tmp2="tmp_add2_$$"
tmp3="tmp_add3_$$"
tmp4="tmp_add4_$$"

for (( i="$file1_rowCount"; i>0;i=i-1)) 
do  
    #get single row, store in temp file
    cat $infile1 | tail -n $i | head -n 1 > $tmp1
    cat $infile2 | tail -n $i | head -n 1 > $tmp2

    for (( j=1; j <= $file1_colCount;j=j+1)) 
    do
        #extract jth element of row into e1, e2
        e1=$(cut -f $j $tmp1)
        e2=$(cut -f $j $tmp2)

        #tmp3 containing current summed row elements separated by '\n'
        expr $e1 + $e2  >> $tmp3
    done

	#tmp4 contains final result matrix	   
    result_row="$(cat $tmp3 | tr '\n' '\t')"
    echo "${result_row%?}" >> $tmp4

    rm $tmp3

	 
done

cat $tmp4

rm $tmp1 $tmp2 $tmp4

return
}


multiply(){

#calculates dimension of both matrices, sets global variables
countDimensionsM1
countDimensionsM2

file2_transposed="tmp_mul1_$$"
tmp_m1_row="tmp_mul2_$$"
tmp_m2_row="tmp_mul3_$$"
tmp_results_row="tmp_mul4_$$"
tmp_results="tmp_mul5_$$"

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

    for (( k="$file2_colCount"; k>0;k=k-1)) 
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
        
        # write single element to current result row
        echo $accum >> $tmp_results_row
        
    done

   	#tmp4 contains final result matrix	   
    result_row="$(cat $tmp_results_row | tr '\n' '\t')"
    #echo "'$result_row'"
    echo "${result_row%?}" >> $tmp_results
    rm $tmp_results_row


done

cat $tmp_results

rm -f $file2_transposed $tmp_m1_row $tmp_m2_row $tmp_results_row $tmp_results

return
}


#main function handler
#interpret parameters, call correct function

#echo "all parameters:$@"
#echo "number of parameters:$#"
#echo "parameter 0:$0"
#echo "parameter 1:$1"


if [[ ($1 = "dims" ||  $1 = "transpose" || $1 = "mean") ]]
then
    #echo "case number 1 -- one parameter functions"

    if [ "$#" = "1" ]
    then
        cat > "$infile1"
    elif [ "$#" = "2" ]
    then
        infile1=$2
    fi

    #check that there is a file name 
    if [ "$infile1" = "" ]
    then
        echo "No input file received" >&2  ##sending to standard error
        exit 1 ##error        
    fi

    #two parameters for dim/transpose/mean cause error
    if [ "$#" = "3" ]
    then
        echo "Too many parameters" >&2  ##sending to standard error
        exit 1 ##error        
    fi

    #run function
    $1

elif [[ ($1 = "add" || $1 = "multiply" ) ]] 
then
    infile1=$2
    infile2=$3
    #echo "case number 2 -- two parameter functions"

    #run function
    $1
else
    echo "Incorrect parameter combination" >&2  ##sending to standard error
	exit 1 ##error
fi
