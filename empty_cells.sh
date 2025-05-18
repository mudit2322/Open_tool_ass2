#!/usr/bin/env bash
# empty_cells.sh: Count empty cells in each column of a delimited file
# Usage: empty_cells.sh <input-file> <separator>

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input-file> <separator>" >&2
  exit 1
fi

file="$1"
sep="$2"

awk -v FS="$sep" '
NR == 1 {
    n = NF
    for (i = 1; i <= n; i++) {
        header[i] = $i      # store column headers
        counts[i] = 0       # initialize counts
    }
    next
}
{
    for (i = 1; i <= n; i++) {
        if ($i == "") counts[i]++  # increment if empty cell
    }
}
END {
    for (i = 1; i <= n; i++) {
        print header[i] ": " counts[i]
    }
}
' "$file"
