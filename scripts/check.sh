string=$1
echo $string
if [ ${#string} -ge 5 ]; then echo "error" ; exit
else echo "done"
fi
