#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <input-file>"
    exit 1
fi

input="$1"

# Extract max ID
max_id=$(awk -F ";" 'NR>1 && $1 ~ /^[0-9]+$/ { if($1+0 > max) max = $1+0 } END { print max }' "$input")
next_id=$((max_id + 1))

awk -v next_id="$next_id" '
BEGIN { FS=";"; OFS="\t" }
NR == 1 { for (i = 1; i <= NF; i++) header[i] = $i; print $0; next }

{
    if ($1 == "" || $1 ~ /^ *$/) {
        $1 = next_id++
    }
    for (i = 1; i <= NF; i++) {
        gsub(",", ".", $i)               # Fix decimal points
        gsub(/\r/, "", $i)              # Remove Windows CR
        gsub(/[^[:ascii:]]/, "", $i)    # Remove non-ASCII
    }
    print
}
' "$input"
