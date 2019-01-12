#!/bin/bash

#global variables
infile1=""
infile2=""
rowSize=0
colSize=0

dims(){
    while read row
    do
        count=0
        for i in $row
        do
            ((count++))
        done

        #set column size using first row, verify other rows are same 	
        if [ "$rowSize" -eq 0 ]
        then
            echo "first row"
            colSize="$count"
        else
            if [ "$count" -ne "$colSize" ]
            then
                echo "ERROR -- matrix not complete"
            fi
        fi

        ((rowSize++))
    done < $infile1

    echo "$rowSize $colSize"
    return
}

transpose(){
    for (( i=1; i<"$colSize";i=i+1))
    do
        #takes single column from input, tranposes and sends to output
        cut -f $i $infile1 | tr '\n' '\t' >> $outfile    
        echo -e "" >> $outfile          #echo empty string adds end of line
    done
    return
}
	

#main function handler
#interpret parameters, call correct function

echo "all parameters:$@"
echo "number of parameters:$#"
echo "parameter 0:$0"
echo "parameter 1:$1"

if [[ $# -eq 2 ]]
then
    infile1=$2 
    echo "case number 1 -- one parameter functions"
    $1
elif [[ $# -eq 3 ]] 
then
    infile1=$2
    infile2=$3
    echo "case number 2 -- two parameter functions"
else
    echo "Incorrect parameter combination"
fi