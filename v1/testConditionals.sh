echo "parameter 1:$1"

if [[ ($1 = "dims" ||  $1 = "transpose" || $1 = "mean") ]]
then
    echo "case number 1 -- one parameter functions"
else
    echo "other"
fi

