#!/bin/bash

#global variables
infile1="tmp_infile_$$" #need temp for input 1 if matrix piped in
infile2=""
outfile=""

file1_rowCount=0
file1_colCount=0
file2_rowCount=0
file2_colCount=0



countDimensions(){
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

    # if there is a second matrix parameter count dimensions
    if [[ $# -eq 3 ]]
    then

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

    fi
    return
}


#
dims(){
    #check if file size >0
    if [ -s "$infile1" ]
    then
        countDimensions
    else
        echo "ERROR: empty matrix" >&2  ##sending to standard error
        exit 1 ##error  
    fi



    echo "$file1_rowCount $file1_colCount"
    return
}

transpose(){
    countDimensions
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
    countDimensions

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
echo "add function"
return
}

multiply(){
echo "mult function"
return
}


#main function handler
#interpret parameters, call correct function

#echo "all parameters:$@"
#echo "number of parameters:$#"
#echo "parameter 0:$0"
#echo "parameter 1:$1"


if [[ ($1 -eq "dims" ||  $1 -eq "transpose" || $1 -eq "mean") ]]
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
elif [[ $# -eq 3 && (  $1 -eq "add" || $1 -eq "multiply" ) ]] 
then
    infile1=$2
    infile2=$3
    echo "case number 2 -- two parameter functions"
else
    echo "Incorrect parameter combination" >&2  ##sending to standard error
	exit 1 ##error
fi
