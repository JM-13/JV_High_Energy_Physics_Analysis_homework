#!/bin/bash

c_green=$(tput setaf 14) # \033[96
c_orange=$(tput setaf 3) # \033[33
c_red=$(tput setaf 1)    # \033[31

tmp_f1='/tmp/folder1.txt'
tmp_f2='/tmp/folder2.txt'

deep=false

case $# in
2) folder1="$1"; folder2="$2" ;;
3) case $1 in
    -deep) folder1="$2"; folder2="$3"; deep=true; ;;
    *) exit 1 ;;
   esac
;;

*) exit 1 ;;
esac

tree -a --noreport --filesfirst "$folder1" > $tmp_f1
tree -a --noreport --filesfirst "$folder2" > $tmp_f2

if $deep; then
    tmp_fd1='/tmp/folderd1.txt'
    tmp_fd2='/tmp/folderd2.txt'

    tree -af --noreport --filesfirst "$folder1" > $tmp_fd1
    tree -af --noreport --filesfirst "$folder2" > $tmp_fd2

    sed -i 's/└──/├──/g'       $tmp_fd1 $tmp_fd2
    sed -i 's/│  /│     /g'    $tmp_fd1 $tmp_fd2
    sed -i "s/\s\{4,\}/│   /g" $tmp_fd1 $tmp_fd2

    sed -i 's/├── //g'   $tmp_fd1 $tmp_fd2
    sed -i 's/│     //g' $tmp_fd1 $tmp_fd2
    sed -i 's/│   //g'   $tmp_fd1 $tmp_fd2
    sed -i 's/│  //g'    $tmp_fd1 $tmp_fd2
fi

sed -i 's/└──/├──/g'       $tmp_f1 $tmp_f2
sed -i 's/│  /│     /g'    $tmp_f1 $tmp_f2
sed -i "s/\s\{4,\}/│   /g" $tmp_f1 $tmp_f2

matching1=$(grep -xnf $tmp_f2 $tmp_f1 | cut -f1 -d:)
matching2=$(grep -xnf $tmp_f1 $tmp_f2 | cut -f1 -d:)

if $deep; then
:
fi

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
    if [[ $i -gt $len1 ]]; then
        line1=" "
    fi

    line2=$(head -n $i $tmp_f2 | tail -1)
    if [[ $i -gt $len2 ]]; then
        line2=" "
    fi

    printf "%s %s %s\n" "$line1" "${pad:${#line1}}" "$line2"
done

tput sgr0; echo ""; exit 0;

