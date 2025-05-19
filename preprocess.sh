#!/usr/bin/env bash
# preprocess.sh: Clean a semicolon-delimited spreadsheet for analysis
# Usage: preprocess.sh <input-file> [output-file]
# Mudit Mamgain 23931717

# Enable strict error handling:
# -e: exit on error
# -u: treat unset variables as an error
# -o pipefail: fail if any command in a pipeline fails
set -euo pipefail

# Check that either 1 or 2 arguments are provided
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <input-file> [output-file]" >&2
  exit 1
fi

# Assign input file and optional output file (default to stdout if not provided)
input="$1"
output="${2:-/dev/stdout}"

# Check that the input file exists and is readable
if [ ! -f "$input" ] || [ ! -r "$input" ]; then
  echo "Error: File '$input' does not exist or is not readable." >&2
  exit 2
fi

# Create two temporary files for intermediate processing
tmp1=$(mktemp)
tmp2=$(mktemp)

# Ensure temporary files are removed when the script exits
trap 'rm -f "$tmp1" "$tmp2"' EXIT

# Step 1: Remove Windows carriage return characters (CRLF -> LF)
echo "# Converting CRLF to LF and removing carriage returns..." >&2
tr -d '\r' < "$input" > "$tmp1"

# Step 2: Convert semicolon delimiters to tab characters
echo "# Changing separators from ';' to tab..." >&2
tr ';' '\t' < "$tmp1" > "$tmp2"

# Step 3: Convert decimal numbers using comma (e.g., 3,14) to dot format (3.14)
echo "# Converting comma decimals to dot decimals..." >&2
sed -E 's/([0-9]),([0-9]+)/\1.\2/g' "$tmp2" > "$tmp1"

# Step 4: Strip out non-ASCII characters (preserving tabs, newlines, carriage returns, and printable characters)
echo "# Stripping non-ASCII characters..." >&2
tr -cd '\11\12\15\40-\176' < "$tmp1" > "$tmp2"

# Step 5: Find the highest existing numeric ID in the first column (skip header row)
maxid=$(awk -F"\t" 'NR>1 && $1 ~ /^[0-9]+$/ { if($1>m) m=$1 } END { print m+0 }' "$tmp2")

# Step 6: Fill in any missing (empty) IDs in the first column with incrementing values starting from maxid + 1
echo "# Filling empty IDs starting from $((maxid+1))..." >&2
awk -F"\t" -v OFS="\t" -v maxid="$maxid" '
NR==1 { print; next }  # Print the header row as-is
{
  if ($1 == "") {
    $1 = ++maxid       # Replace empty ID with next available ID
  }
  print
}' "$tmp2" > "$output"
