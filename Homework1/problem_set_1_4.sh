#!/bin/bash

case $1 in
-d|--date)   git checkout "$2@{$3}" ;;

-n|--number) git checkout "$2@{$3}" ;;

-N|--new-branch) git branch "$2"; echo "Created branch $2";;

-D|--del-branch) git branch -D "$2";;

-S|--sel-branch) git checkout "$2";;

-h|--help)   echo '
usage: problem_set_1_4.sh [<options>] <branch> <args>

    -d, --date <branch> <date>           checkout a branch by date (YYYY-MM-DD HH:MM:SS)
    -n, --number <branch> <number>       checkout a branch by commit number (bigger number is older commit)
    -N, --new-branch <branch>            create new branch
    -D, --del-branch <branch>            delete branch
    -S, --sel-branch <branch>            switch to branch
' ;;

*) echo 'See problem_set_1_4.sh -h or --help for available commands and usage' ;;
esac
