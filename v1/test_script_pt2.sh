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

# NAME
# 	ident - generate identity matrix of specified size
# SYNOPSIS
#		ident ROWS COLS
function ident(){
	y=0
	while [ $y -lt $1 ]
	do
		x=0
		((y++))
		while [ $x -lt $2 ]
		do
			((x++))
			if [ $x -eq $y ]
			then
				echo -n 1
			else
				echo -n 0
			fi
			if [ $x -ne $2 ]
			then
				echo -ne "\t"
			else
				echo
			fi
		done
	done
}

# NAME
#	Error
# SYNOPSIS
#	Dump error message and exit

err(){
	echo $1 >&2
	exit 1
}


if [ $# -ge 1 ] 
then
	if [ -f $1 ]
	then 
		cmd=$1
	else
		err "Given file not found."
	fi
		
else
	err "Usage: $0 [bash_program_file]"
fi

chmod +x "$1" # Make sure submission is executable
dos2unix "$1" # Fix windows newlines (^M errors)

cd "$(dirname "$1")" # Change working directory to submission file
cmd="$(basename "$1")"



total=0
score=0

# Generate temp files to use for grading purposes
m1="$(mktemp matrix.XXXXX)"
m2="$(mktemp matrix.XXXXX)"
m3="$(mktemp matrix.XXXXX)"
m4="$(mktemp matrix.XXXXX)"
m5="$(mktemp matrix.XXXXX)"
outpipe="$(mktemp stdout.XXXXX)"
outpipe2="$(mktemp stdout.XXXXX)"
errpipe="$(mktemp stderr.XXXXX)"
errpipe2="$(mktemp stderr.XXXXX)"

trap "rm -rf $m1 $m2 $m3 $m4 $m5 $outpipe $outpipe2 $errpipe $errpipe2; trap - EXIT" INT HUP TERM EXIT 



echo "-93	-92	29	-45	-55	-87	-36	39	-88	71	7	-69	52	45	-22
50	-27	85	11	-76	-3	23	68	58	-5	34	7	-29	-49	41
-61	2	-44	-62	47	-77	33	6	-7	55	-45	99	2	20	89
52	-97	57	-39	-76	62	24	69	-74	89	-76	1	-46	-27	-9
55	77	42	10	-98	-22	15	-48	26	33	-7	29	-34	78	-19
23	25	-40	16	-63	-12	42	45	-22	20	44	-23	78	-50	17
-67	14	-9	-58	38	-78	2	99	-87	-92	-34	-29	-7	-31	11
65	-32	27	91	-46	-13	-71	37	24	-5	34	-92	6	15	-15
-49	23	-52	-9	59	-57	-78	-10	17	-27	44	-34	-62	22	-94
-45	-45	88	-12	-64	1	-60	-35	11	1	-10	52	5	52	-17
-91	61	90	22	82	-9	82	85	10	56	18	4	-18	-92	-46
31	98	47	-12	-60	20	54	-8	92	24	-71	-23	24	91	37
-12	98	-13	66	72	-14	88	51	75	5	40	-91	91	-94	26
0	60	-41	6	28	-54	97	56	40	-17	94	-92	-23	-3	-91
10	-26	78	-22	-55	73	-82	-49	-26	-63	-80	8	97	87	-27
80	17	90	22	6	45	23	91	16	-93	-38	-64	-75	35	61
21	-24	-38	92	-43	98	-14	35	39	-65	-20	65	65	19	-81
79	-32	62	-93	89	19	-83	-47	45	20	93	49	43	73	80
24	81	19	-15	48	-46	-23	-63	65	2	75	-16	1	-98	14
-40	-68	-89	-10	90	29	3	-15	58	86	-85	36	-55	31	-79" > "$m1"

echo "matrix 1:"
cat $m1

echo "-93	50	-61	52	55	23	-67	65	-49	-45	-91	31	-12	0	10	80	21	79	24	-40
-92	-27	2	-97	77	25	14	-32	23	-45	61	98	98	60	-26	17	-24	-32	81	-68
29	85	-44	57	42	-40	-9	27	-52	88	90	47	-13	-41	78	90	-38	62	19	-89
-45	11	-62	-39	10	16	-58	91	-9	-12	22	-12	66	6	-22	22	92	-93	-15	-10
-55	-76	47	-76	-98	-63	38	-46	59	-64	82	-60	72	28	-55	6	-43	89	48	90
-87	-3	-77	62	-22	-12	-78	-13	-57	1	-9	20	-14	-54	73	45	98	19	-46	29
-36	23	33	24	15	42	2	-71	-78	-60	82	54	88	97	-82	23	-14	-83	-23	3
39	68	6	69	-48	45	99	37	-10	-35	85	-8	51	56	-49	91	35	-47	-63	-15
-88	58	-7	-74	26	-22	-87	24	17	11	10	92	75	40	-26	16	39	45	65	58
71	-5	55	89	33	20	-92	-5	-27	1	56	24	5	-17	-63	-93	-65	20	2	86
7	34	-45	-76	-7	44	-34	34	44	-10	18	-71	40	94	-80	-38	-20	93	75	-85
-69	7	99	1	29	-23	-29	-92	-34	52	4	-23	-91	-92	8	-64	65	49	-16	36
52	-29	2	-46	-34	78	-7	6	-62	5	-18	24	91	-23	97	-75	65	43	1	-55
45	-49	20	-27	78	-50	-31	15	22	52	-92	91	-94	-3	87	35	19	73	-98	31
-22	41	89	-9	-19	17	11	-15	-94	-17	-46	37	26	-91	-27	61	-81	80	14	-79" > "$m2"

echo "matrix 2:"
cat -A $m2


echo "Transposing hardcoded matrix (10pt):"
score=10
SECONDS=0
./"$cmd" transpose "$m1" 1>"$outpipe" 2>"$errpipe" &
while
	[ $SECONDS -lt 30 ] && kill -0 $! &>/dev/null
do
	:
done
if
	kill -9 $! &>/dev/null
then
	echo -e "\u26D4 Hung process (killed)"
	score=0
else 
	wait $!
	result=$?
	if [ "$result" -ne 0 ]
	then
		score=0
		echo -e "\u26D4 Returned $result"
	fi
	if
		! cmp -s "$outpipe" "$m2"
	then
		score=0
		echo -e "\u26D4 Transposed matrix does not match known result"
	fi
	if [ -s "$errpipe" ]
	then
		score=0
		echo -e "\u26D4 stderr is non-empty"
	fi
fi
if [ $score -ne 0 ]
then
	echo -e "\u2705 Passed!"
fi
((points+=score))

echo "result of tranpose m1"
cat -A $outpipe


echo "Transpose involution test on m3 (5pt):" 
score=5
SECONDS=0
./"$cmd" transpose "$m3" 1>"$outpipe" 2>"$errpipe" &
while
	[ $SECONDS -lt 30 ] && kill -0 $! &>/dev/null
do
	:
done
if
	kill -9 $! &>/dev/null
then
	echo -e "\u26D4 Hung process (killed)"
	score=0
else 
	wait $!
	result=$?
	if [ "$result" -ne 0 ]
	then
		score=0
		echo -e "\u26D4 Returned $result"
	fi
	if [ -s "$errpipe" ]
	then
		score=0
		echo -e "\u26D4 stderr is non-empty"
	fi
fi
SECONDS=0
./"$cmd" transpose "$outpipe" 1>"$outpipe2" 2>"$errpipe2" & # Transpose result
while
	[ $SECONDS -lt 30 ] && kill -0 $! &>/dev/null
do
	:
done
if
	kill -9 $! &>/dev/null
then
	echo -e "\u26D4 Hung process (killed)"
	score=0
else 
	wait $!
	result=$?
	if [ "$result" -ne 0 ]
	then
		score=0
		echo -e "\u26D4 Returned $result"
	fi
	if [ -s "$errpipe2" ]
	then
		score=0
		echo -e "\u26D4 stderr is non-empty"
	fi
fi
if
	! cmp -s "$outpipe2" "$m3"
then
	score=0
	echo -e "\u26D4 Transpose is not involutory"
fi
if [ $score -ne 0 ]
then
	echo -e "\u2705 Passed!"
fi
((points+=score))
