#!/usr/bin/env bash
# empty_cells.sh: Count empty or whitespace-only cells in each column of a delimited file
# Usage: ./empty_cells.sh <input-file> <separator>

# ----------------------------
# Check that exactly 2 arguments are provided: input file and separator
# ----------------------------
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input-file> <separator>" >&2
  exit 1
fi

file="$1"      # First argument is the path to the input file
sep="$2"       # Second argument is the column separator (e.g., ";" for CSV with semicolons)

# ----------------------------
# Use awk to process the file line by line
# ----------------------------
awk -v FS="$sep" '                         # Set the field separator (FS) to whatever user passed (e.g., ";" or ",")
BEGIN {
  OFS="\t"                                 # Output fields separated by tab (for cleaner output)
}

# ----------------------------
# For every line, remove carriage return at the end (for Windows-formatted files)
# ----------------------------
{
  sub(/\r$/, "")                           # Removes trailing carriage return \r if present
}

# ----------------------------
# Process the first line (header row)
# ----------------------------
NR == 1 {
  n = NF                                   # Count how many fields (columns) are in the header
  for (i = 1; i <= NF; i++) {
    gsub(/^ +| +$/, "", $i)                # Remove any leading/trailing spaces from each header
    headers[i] = $i                        # Store the header name for column i
    empty[i] = 0                           # Initialize empty count for column i to 0
  }
  next                                     # Skip to the next line (don’t process the header again)
}

# ----------------------------
# Process the rest of the rows (data rows)
# ----------------------------
{
  for (i = 1; i <= n; i++) {
    val = $i
    gsub(/^ +| +$/, "", val)               # Remove spaces around each cell value
    if (val == "") {
      empty[i]++                           # If the cell is empty or only had spaces, count it as empty
    }
  }
}

# ----------------------------
# After reading all lines, print how many empty cells were in each column
# ----------------------------
END {
  for (i = 1; i <= n; i++) {
    col = headers[i]
    if (col == "") {
      col = "[Unnamed Column " i "]"       # If the header is blank, give it a placeholder name
    }
    print col ": " empty[i]                # Print column name and the count of empty cells
  }
}
' "$file"
