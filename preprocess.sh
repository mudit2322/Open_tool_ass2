#!/usr/bin/env bash
# preprocess.sh: Clean a semicolon-delimited spreadsheet for analysis
# Usage: preprocess.sh <input-file>

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <input-file>" >&2
  exit 1
fi

input="$1"
tmp1=$(mktemp)
tmp2=$(mktemp)

echo "# Converting CRLF to LF and removing carriage returns..." >&2
tr -d '\r' < "$input" > "$tmp1"

echo "# Changing separators from ';' to tab..." >&2
tr ';' '\t' < "$tmp1" > "$tmp2"

echo "# Converting comma decimals to dot decimals..." >&2
# Replace comma decimals like 3,5 with 3.5 (handles optional second digit)
sed -E 's/([0-9]),([0-9]+)/\1.\2/g' "$tmp2" > "$tmp1"

echo "# Stripping non-ASCII characters..." >&2
tr -cd '\11\12\15\40-\176' < "$tmp1" > "$tmp2"

# Find max numeric ID in first column, ignoring header
maxid=$(awk -F"\t" 'NR>1 && $1 ~ /^[0-9]+$/ { if($1>m) m=$1 } END { print m+0 }' "$tmp2")

echo "# Filling empty IDs starting from $((maxid+1))..." >&2
awk -F"\t" -v OFS="\t" -v maxid="$maxid" '
NR==1 { print; next }
{
  if ($1 == "") {
    $1 = ++maxid
  }
  print
}' "$tmp2"

rm -f "$tmp1" "$tmp2"
