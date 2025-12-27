#!/bin/bash

# tireks33@gmail.com
######################################################
# Search dynamic linked binaries dependencies status #
######################################################

# User variables ->

# show additional entries processing info
debug=false # true

# show info about dll's that already installed 
show_satisfied=false # true

# recursive search mode default value 
# (can be modified by first program
# argument '-r'/'--recursive')
_Recursive=false

# <-

print_edges() {
    local symb='*'
    if [ $# -gt 0 ] ; then
        symb="$1"
    fi
    local cols_n=$(tput cols)
    for i in $(seq 1 "${cols_n}") ; do
        printf "${symb}"
    done
        echo ""
    #printf "%.0s" $(seq 1 "${cols_n}")
}



if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
    me=$(basename "$0")
    echo -e "[${me}] -- ldd-based script.\nProvide file/dir/symlink paths entries"\
    " as a script arguments to get detailed info about dependencies. Pass '-r'/"\
    "\"--recursive\" as first argument to enable recursive search for directories"\
    ". '-h'/\"--help\" to show this help."
    exit 0
fi

if [[ "${1}" == "-r" || "${1}" == "--recursive" ]]; then
    shift
    _Recursive=true
fi

if [ $# -eq 0 ]
    then
        echo "No arguments supplied, need at least 1."
        exit 1
fi

print_edges

if [ $_Recursive = true ] ; then
    echo -e "->[Recursive search enabled]\n"
fi

echo "[Preparing stage]"$'\n'

echo "Please wait.."$'\n'

argArr=()

for argi in "${@}"
do
    # if entry is a directory
    if [[ -d $argi ]]; then
        $debug && echo "'${argi}' is a directory"
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
                $debug && echo "'${entry}' is a sub-directory"
                fi 
                argArr+=("${entry}")
            done
        fi
    # if entry is a link (soft/symlink)
    elif [[ -L "${argi}" ]] ; then
        $debug && printf "'${argi}' is a symlink."
        if [[ -e "${argi}" ]] ; then
            $debug && printf " And it's valid (not broken)"
            readl="$(readlink -f ${argi})"
            $debug && printf " -> \"${readl}\""
            argArr+=("${readl}")
        else
            $debug && printf " And it's dangling! (BROKEN)"
        fi
        $debug && printf "\n"
    
    # if simple file (or hardlink)
    elif [[ -f $argi ]] ; then
        argArr+=("${argi}")
    else
        $debug && echo "'${argi}' is not a file/symlink/directory, skip.."
    fi
done


not_satisfied_g_cnt=0
not_satisfied_g_arr=()

if (( ${#argArr[@]} != 0 )) ; then

    args2ldd=()

    for fil in "${argArr[@]}"
    do
        $debug && echo "File for dependency check -> \"${fil}\""
        checked_file=$(file "${fil}" | awk -F: '$2 ~ "dynamically linked" {print $1}')
        if [[ -z "${checked_file}" ]]; then
            $debug && echo "File \"${fil}\" is not a dynamically linked binary.." # $'\n'
        else
            args2ldd+=("${checked_file}")
        fi
    done

    bin_amount="${#args2ldd[@]}"

    $debug && echo $'\n'"Total binary files amount to check: ${#args2ldd[@]}."

    if [ $bin_amount -eq 0 ] ; then
        echo "None of the files provided are dynamically linked binary. Exiting.."
    else

        COUNTER=0

        $debug && echo $'\n'"[Begin check]:"$'\n'

        for elem in "${args2ldd[@]}"
        do
            ((COUNTER++))
            elem_str="[${COUNTER}]'${elem}'"
            echo "${elem_str}:"

            satisfied_cnt=0
            not_satisfied_cnt=0
            overall_dep=0

            lddRes=()
            
            readarray -t lddRes< <(ldd "${elem}") # what a strange syntax though!!>_<

            for i in "${!lddRes[@]}"
            do
                sub_cnt=$((i + 1))
                lddRes[$i]="$(echo -e "${lddRes[$i]}" | sed -e 's/^[[:space:]]*//' )"  
            done
            
            joinNLineFalse=""
            joinNLineTrue=""

            for inde in "${!lddRes[@]}";
            do
                sub_cnt=$((inde + 1))

                temp_entry="$( echo -e "${lddRes[${inde}]}" | sed -e "s/^/\t[${COUNTER}].{${sub_cnt}} -- /" )"

                if [[ "${temp_entry}" != *"not found"* ]]; then
                    
                    if [ $show_satisfied == true ] ; then
                        joinNLineTrue+="${temp_entry}\n"
                        ((satisfied_cnt++))
                    fi

                else

                    joinNLineFalse+="${temp_entry}\n"
                    ((not_satisfied_g_cnt++))
                    ((not_satisfied_cnt++))
                
                fi

                ((overall_dep++))

            done

            $debug && echo "Overall dependencies count: ${overall_dep}."

            if [ "${show_satisfied}" = true ] ; then
                
                echo "[Already satisfied dependencies list(${satisfied_cnt})]"
                 
                echo -e "${joinNLineTrue}"
                
            fi

            if [ "${not_satisfied_cnt}" -gt 0 ] ; then
                not_satisfied_g_arr+=("${elem_str}(${not_satisfied_cnt})")
            fi


            $debug && echo "Unsatisfied dependencies: ${not_satisfied_cnt}."

            if [ ! -z "${joinNLineFalse}" ]
            then

                echo "[Missing dependencies list(${not_satisfied_cnt})]"
                echo -e "${joinNLineFalse}"
            else
                echo -e "[Everything is OK]\n"
            fi

            print_edges '-'
            printf "\n"
        done
    fi
else   
    echo "Nothing to check. Exiting.."
fi

if [ "${not_satisfied_g_cnt}" -gt 0 ] ; then
    echo "Total unsatisfied dependencies: ${not_satisfied_g_cnt}."
    printf "Files with unsatisfied dependencies: "
fi

ns_arr_len="${#not_satisfied_g_arr[@]}"

for ind_ in "${!not_satisfied_g_arr[@]}"
do
    printf "%s" "${not_satisfied_g_arr[${ind_}]}"
    if [[ $ind_ -ne $((ns_arr_len - 1)) ]] ; then
        printf ", "
    else
        printf ".\n"
    fi
done

echo "[Done]"

print_edges



