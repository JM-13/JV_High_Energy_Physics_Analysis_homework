#!/bin/bash

case $1 in
-date)   git checkout "$2@{$3}" ;;

-number) git checkout "$2@{$3}" ;;

-help)   echo '
usage: problem_set_1_3.sh [<options>] <branch> <args>

    -date <branch> <date>           checkout a branch by date (YYYY-MM-DD HH:MM:SS)
    -number <branch> <number>       checkout a branch by commit number (bigger number is older commit)
' ;;
*) echo 'See problem_set_1_3.sh -help for available commands and usage' ;;
esac
