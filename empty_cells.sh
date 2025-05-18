#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <filename> <separator>"
    exit 1
fi

file="$1"
sep="$2"

# Read header
IFS="$sep" read -r -a headers < "$file"

# Initialize array of counters
declare -a counters
for ((i = 0; i < ${#headers[@]}; i++)); do
    counters[$i]=0
done

# Process rows
tail -n +2 "$file" | while IFS="$sep" read -r -a fields; do
    for ((i = 0; i < ${#headers[@]}; i++)); do
        if [[ -z "${fields[$i]// /}" ]]; then
            ((counters[$i]++))
        fi
    done
done

# Output results
for ((i = 0; i < ${#headers[@]}; i++)); do
    echo "${headers[$i]}: ${counters[$i]}"
done
