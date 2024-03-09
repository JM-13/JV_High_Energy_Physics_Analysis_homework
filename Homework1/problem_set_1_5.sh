#!/bin/bash

c_green=$(tput setaf 14) # \033[96
c_orange=$(tput setaf 3) # \033[33
c_red=$(tput setaf 1)    # \033[31

tmp_f1='/tmp/folder1.txt'
tmp_f2='/tmp/folder2.txt'

tree -U --noreport $1 > $tmp_f1
tree -U --noreport $2 > $tmp_f2


sed -i 's/└──/├──/g' $tmp_f1 $tmp_f2
sed  -i "s/\s\{4,\}/│   /g" $tmp_f1 $tmp_f2

matching1=$(grep -xnf $tmp_f2 $tmp_f1 | cut -f1 -d:)
matching2=$(grep -xnf $tmp_f1 $tmp_f2 | cut -f1 -d:)

sed -i "s/^/$c_red/" $tmp_f1 $tmp_f2

for i in $matching1
do
    sed -i "$i s!\[31!\[96!" $tmp_f1
done

for i in $matching2
do
    sed -i "$i s!\[31!\[96!" $tmp_f2
done


len1=$(wc -l <  $tmp_f1)
len2=$(wc -l <  $tmp_f2)

if [[ $len1 -gt $len2 ]]; then
    len=$len1
else
    len=$len2
fi

padding=$(($(wc -L < $tmp_f1)+1))
pad=$(printf '%*s' "$padding")

for i in $(seq $len)
do
    line1=$(head -n $i $tmp_f1 | tail -1)
    line2=$(head -n $i $tmp_f2 | tail -1)

    printf "%s %s %s\n" "$line1" "${pad:${#line1}}" "$line2"
done

tput sgr0; echo ""; exit 0;

