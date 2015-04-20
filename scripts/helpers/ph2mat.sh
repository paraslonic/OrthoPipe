perl -ne 's/\s+/ /g; if(/^\w/) { print "\n$_"; } else {print $_};' $1 > $2 
sed -i '1d' $2
sed -i 's/[ ]\+/ /g' $2
sed -i "s/[ ]$//" $2
