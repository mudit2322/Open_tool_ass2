#!/usr/bin/env bash

# Check if the script received exactly 2 arguments: the input file and the field separator
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input-file> <separator>" >&2
  exit 1
fi

# Store the input arguments into variables for better readability
file="$1"
sep="$2"

# Use awk to process the file with the given separator
awk -v FS="$sep" '
BEGIN {
  # Set the output field separator to tab for consistency
  OFS="\t"
}

{
  # Remove trailing carriage return (in case the file has Windows line endings)
  sub(/\r$/, "")
}

# Process the header row (first line)
NR == 1 {
  n = NF  # Total number of fields (columns)
  for (i = 1; i <= NF; i++) {
    # Trim spaces from each column name
    gsub(/^ +| +$/, "", $i)
    headers[i] = $i         # Store the column name
    empty[i] = 0            # Initialize the empty cell counter for each column
  }
  next  # Skip to the next line (data starts from line 2)
}

# Process the data rows
{
  for (i = 1; i <= n; i++) {
    val = $i
    # Trim spaces from each cell value
    gsub(/^ +| +$/, "", val)
    # Check if the cell is empty
    if (val == "") {
      empty[i]++
    }
  }
}

END {
  # Print the number of empty cells for each column
  for (i = 1; i <= n; i++) {
    col = headers[i]
    # If a header was missing, assign a placeholder name
    if (col == "") {
      col = "[Unnamed Column " i "]"
    }
    # Print the column name followed by the count of empty cells
    print col ": " empty[i]
  }
}
' "$file"
