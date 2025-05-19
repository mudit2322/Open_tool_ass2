#!/usr/bin/env bash
# empty_cells.sh: Count empty or whitespace-only cells per column
# Usage: empty_cells.sh <input-file> <separator>

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input-file> <separator>" >&2
  exit 1
fi

file="$1"
sep="$2"

awk -v FS="$sep" '
BEGIN {
  OFS="\t"
}
{
  # Strip carriage returns (for Windows \r\n line endings)
  sub(/\r$/, "")
}
NR == 1 {
  # Trim and store header
  n = NF
  for (i = 1; i <= NF; i++) {
    gsub(/^ +| +$/, "", $i)
    headers[i] = $i
    empty[i] = 0
  }
  next
}
{
  for (i = 1; i <= n; i++) {
    val = $i
    gsub(/^ +| +$/, "", val)
    if (val == "") {
      empty[i]++
    }
  }
}
END {
  for (i = 1; i <= n; i++) {
    col = headers[i]
    if (col == "") {
      col = "[Unnamed Column " i "]"
    }
    print col ": " empty[i]
  }
}
' "$file"
