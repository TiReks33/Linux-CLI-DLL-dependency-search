#!/bin/bash

_Recursive=false

if [[ "${1}" == "-r" || "${1}" == "--recursive" ]]; then
    shift
    _Recursive=true
   echo "_Recursive=${_Recursive}"
fi

if [ $# -eq 0 ]
    then
        echo "No arguments supplied, need at least 1"
        exit 1
fi

argArr=()

for argi in "${@}"
do
    if [[ -f $argi ]] ; then
        argArr+=("${argi}")
    elif [[ -d $argi ]]; then
        echo "'${argi}' is a directory"
        elem4ldd=()
        if [ $_Recursive = false ]; then
            elem4ldd=( "$argi"/* )
        else
            shopt -s dotglob globstar
            elem4ldd=( "$argi"/**/* )
        fi
        
        if [ ${#elem4ldd[@]} -gt 1 ] ; then
            for entry in "${elem4ldd[@]}"
            do
                if [[ -d "$entry" ]]; then 
                echo "'${entry}' is a sub-directory"
                fi 
                argArr+=("${entry}")
            done
        fi
    else
        echo "'${argi}' is not a file/directory, skip.."
    fi
done


if [[ -z ${argArr[@]}  ]]; then
    echo "Nothing to check. Exiting.."
    exit 1
fi

args2ldd=(`file ${argArr[@]} | awk -F: '$2 ~ "dynamically linked" {print $1}'`)

echo "Total binary files amount to check: ${#args2ldd[@]}."


COUNTER=0

echo $'\n'"[Begin check]:"$'\n'

for elem in "${args2ldd[@]}"
do
    ((COUNTER++))
    printf "[${COUNTER}.] %s:\n" "${elem}"
    grepRes="`ldd ${elem} | grep "not found"`"
    if [ ! -z "${grepRes}" ]
    then
        printf "%s\n" "${grepRes}"
    else
        printf "\tOK\n"
    fi
    printf "%0.s-" {1..50}
    printf "\n"
done
echo "[End check]"



