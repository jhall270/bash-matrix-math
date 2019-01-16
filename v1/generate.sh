#!/bin/bash

# NAME
# 	generate - generates a matrix of specified size
#	SYNOPSIS
#		generate ROWS COLS MIN MAX
# DESCRIPTION
#		Prints a matrix of size ROWS*COLS with random values ranging from MIN to MAX
function generate(){
	y=0
	a=$3
	b=$4
	while [ $y -lt $1 ]
	do
		x=0
		((y++))
		while [ $x -lt $2 ]
		do
			((x++))
			echo -n $((RANDOM%(b-a+1)+a))
			if [ $x -ne $2 ]
			then
			echo -ne "\t"
			else
				echo
			fi
		done
	done
}

generate 5 6 -10 10 >"test_m1"
generate 6 7 -10 10 >"test_m2"
generate 3 8 -10 10 >"test_m3"