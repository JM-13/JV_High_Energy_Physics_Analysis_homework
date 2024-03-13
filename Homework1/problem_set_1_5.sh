#!/bin/bash

c_green=$(tput setaf 14) # \033[96 # text color green
c_orange=$(tput setaf 3) # \033[33 # text color orange
c_red=$(tput setaf 1)    # \033[31 # text color red

# temporary files
tmp_f1='/tmp/folder1.txt'
tmp_f2='/tmp/folder2.txt'

deep=false # if using deep

case $# in
2) folder1="$1"; folder2="$2" ;; # if 2 arguments set given folders to variables
3) case $1 in                    # if 3 arguments
    -deep) folder1="$2"; folder2="$3"; deep=true; ;; # if -deep set given folders to variables and set deep to true
    *) echo "use $0 [-deep] <folder1> <folder2>"; exit 1 ;;
   esac
;;

*) echo "use $0 [-deep] <folder1> <folder2>"; exit 1 ;;
esac
 # output tree results to files; -a is all files; --noreport is no folder and file count at end; --filesfirst is print all files at curent depth then print contents of folders
tree -a --noreport --filesfirst "$folder1" > $tmp_f1
tree -a --noreport --filesfirst "$folder2" > $tmp_f2

if $deep; then
    # temporary folders for deep
    tmp_fd1='/tmp/folderd1.txt'
    tmp_fd2='/tmp/folderd2.txt'

    # -f adds full path to output
    tree -af --noreport --filesfirst "$folder1" > $tmp_fd1
    tree -af --noreport --filesfirst "$folder2" > $tmp_fd2

    # make text in files uniform
    sed -i 's/└──/├──/g'      $tmp_fd1 $tmp_fd2
    sed -i 's/│   /│  /g'     $tmp_fd1 $tmp_fd2
    sed -i "s/\s\{4,\}/│  /g" $tmp_fd1 $tmp_fd2 # change 4 spaces to
    sed -i 's/├── //g'   $tmp_fd1 $tmp_fd2
    sed -i 's/│  //g'    $tmp_fd1 $tmp_fd2
fi

# make text in files uniform
sed -i 's/└──/├──/g'       $tmp_f1 $tmp_f2
sed -i 's/│   /│  /g'    $tmp_f1 $tmp_f2
sed -i "s/\s\{4,\}/│  /g" $tmp_f1 $tmp_f2 # change 4 spaces to

# use grep to find which lines match in the files
matching1=($(grep -xnf $tmp_f2 $tmp_f1 | cut -f1 -d:)) # array of line numbers in file 1 that match file 2
matching2=($(grep -xnf $tmp_f1 $tmp_f2 | cut -f1 -d:)) # array of line numbers in file 2 that match file 1

if $deep && [[ ${#matching1[@]} -gt 0 ]]; then # if deep true and something matches
    # arrays to store lines that do not have the same sha256sum
    imposters_in_1=()
    imposters_in_2=()
    # temp folders for sha256sum output
    tmp_tmp_f1='/tmp/tmp_sha1.txt'
    tmp_tmp_f2='/tmp/tmp_sha2.txt'

    for i in $(seq ${#matching1[@]}); do
        num=$(($i-1)) # so goes from 0 and does not go over
        # get line with full path using known match
        mach_1=$(head -n ${matching1[$num]} $tmp_fd1 | tail -1)
        mach_2=$(head -n ${matching2[$num]} $tmp_fd2 | tail -1)
        if [[ -d $mach_1 ]]; then # if folder do nothing
            :
        else
            # not using if because sha256sum codes are too big
            sha256sum "$mach_1" | cut -d ' ' -f 1 > "$tmp_tmp_f1"
            sha256sum "$mach_2" | cut -d ' ' -f 1 > "$tmp_tmp_f2"
            sha_mach=$(grep -xnf "$tmp_tmp_f1" "$tmp_tmp_f2" | cut -f1 -d:)

            if [[ $sha_mach -gt 0 ]]; then # if sha256sum match do nothing
                :
            else  # else not matching numbers are added to array
                imposters_in_1+=(${matching1[$num]})
                imposters_in_2+=(${matching2[$num]})
            fi
        fi
    done
fi

sed -i "s/^/$c_red/" $tmp_f1 $tmp_f2 #add color red as prefix to all lines

# when lines match change red to green
for i in ${matching1[@]}; do
    sed -i "$i s!\[31!\[96!" $tmp_f1
done

for i in ${matching2[@]}; do
    sed -i "$i s!\[31!\[96!" $tmp_f2
done

if $deep; then
    # when sha256sum do not match change green to red
    for i in ${imposters_in_1[@]}; do
        sed -i "$i s!\[96!\[33!" $tmp_f1
    done

    for i in ${imposters_in_2[@]}; do
        sed -i "$i s!\[96!\[33!" $tmp_f2
    done
fi

# get how many lines are in each file
len1=$(wc -l < $tmp_f1)
len2=$(wc -l < $tmp_f2)

# set len to biggest line count
if [[ $len1 -gt $len2 ]]; then
    len=$len1
else
    len=$len2
fi

# make padding of spaces so output looks nice
padding=$(($(wc -L < $tmp_f1)+1)) # length of longest line in file 1 +1
pad=$(printf '%*s' "$padding")

for i in $(seq $len); do
    # get line i in file 1 and if i is bigger then file line number set line to color red instead
    line1=$(head -n $i $tmp_f1 | tail -1)
    if [[ $i -gt $len1 ]]; then
        line1="$c_red"
    fi
    # get line i in file 2 and if i is bigger then file line number set line to color red instead
    line2=$(head -n $i $tmp_f2 | tail -1)
    if [[ $i -gt $len2 ]]; then
        line2="$c_red"
    fi

    # print: line 1, adapptive padding of spaces depending on length of line 1, line 2
    printf "%s%s%s\n" "$line1" "${pad:${#line1}}" "$line2"
done

echo "$c_red red    == no matching file"
if $deep; then
    echo "$c_orange orange == same file name but different file"
fi
echo "$c_green green  == same file is in both folders"

# reset color
tput sgr0; echo ""; exit 0;

