# cs344-assignment1

### Description

This is a bash program which does matrix arithmetic.  It is called via the command line with the operation and the input matrices specified.


### Dependencies

Bash shell in a Unix environment

### Directions

From the bash shell call the program by invoking the name of the program, followed by the matrix operation, followed by the matrix input file(s).  The input matrix is a tab-delimited table of values.  Two sample matrices are provided: sampleInput1 and sampleInput2

The following matrix operations are supported

* The dimensionality of the matrix

Command: matrix dims [MATRIX]

Example:
```
matrix dims sampleInput1
```

* The transpose of the matrix

Command: matrix transpose [MATRIX]

Example:
```
matrix transpose sampleInput1
```

* The column means of the matrix

matrix mean [MATRIX]

Example:
```
matrix mean sampleInput1
```

* The matrix addition of two matrices

matrix add [MATRIX_LEFT] [MATRIX_RIGHT]

Example:
```
matrix add sampleInput1 sampleInput2
```

* The matrix multiplication of two matrices
matrix multiply [MATRIX_LEFT] [MATRIX_RIGHT]

Example:
```
matrix multiply sampleInput1 sampleInput2
```
