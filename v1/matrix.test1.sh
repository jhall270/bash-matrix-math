#!/bin/bash

#global variables
infile1="tmp_infile_$$"
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
    countDimensions
    echo "$file1_rowCount $file1_colCount"
    return
}

transpose(){
    countDimensions

    for (( i=1; i<"$file1_colCount";i=i+1))
    do
        #takes single column from input, tranposes and sends to output
        cut -f $i $infile1 | tr '\n' '\t' >> $outfile    
        echo -e "" >> $outfile          #echo empty string adds end of line
    done
    return
}

mean(){
    countDimensions

    tempTransposed="tmp_avg1_$$"
    tempResults="tmp_avg2_$$"

    #step 1: transpose matrix, so can average rows
    for (( i=1; i<="$file1_colCount";i=i+1))
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
        expr $(( (( $sum + (( $file1_rowCount / 2)) * (( ($sum>0) * 2 - 1)) )) / $file1_rowCount )) >> $tempResults
    done < $tempTransposed

    #print results
    cat $tempResults

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
