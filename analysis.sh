#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <cleaned-tsv-file>"
    exit 1
fi

file="$1"

# Get column indices
header=$(head -n 1 "$file")
IFS=$'\t' read -ra cols <<< "$header"

for i in "${!cols[@]}"; do
    case "${cols[$i]}" in
        "Mechanics") mech_col=$((i+1)) ;;
        "Domains") domain_col=$((i+1)) ;;
        "Year Published") year_col=$((i+1)) ;;
        "Rating Average") rating_col=$((i+1)) ;;
        "Complexity Average") complexity_col=$((i+1)) ;;
    esac
done

# 1. Most popular Mechanics and Domain
tail -n +2 "$file" | awk -F'\t' -v m="$mech_col" '
{
    n=split($m, arr, ",")
    for (i=1; i<=n; i++) {
        gsub(/^ +| +$/, "", arr[i])
        if (arr[i] != "") count[arr[i]]++
    }
}
END {
    max = 0
    for (k in count) {
        if (count[k] > max) {
            max = count[k]
            best = k
        }
    }
    print "The most popular game mechanics is", best, "found in", max, "games"
}'


tail -n +2 "$file" | awk -F'\t' -v d="$domain_col" '
{
    n=split($d, arr, ",")
    for (i=1; i<=n; i++) {
        gsub(/^ +| +$/, "", arr[i])
        if (arr[i] != "") count[arr[i]]++
    }
}
END {
    max = 0
    for (k in count) {
        if (count[k] > max) {
            max = count[k]
            best = k
        }
    }
    print "The most game domain is", best, "found in", max, "games"
}'

# 2. Correlation functions
correlation() {
    awk -F'\t' -v x="$1" -v y="$2" '
    {
        if (NR == 1) next
        if ($x != "" && $y != "") {
            xsum += $x
            ysum += $y
            x2sum += ($x)^2
            y2sum += ($y)^2
            xysum += ($x)*($y)
            n++
        }
    }
    END {
        if (n > 0) {
            numerator = n * xysum - xsum * ysum
            denominator = sqrt((n * x2sum - xsum^2) * (n * y2sum - ysum^2))
            corr = (denominator != 0) ? numerator / denominator : 0
            printf "The correlation between %s and %s is %.3f\n", x == '$year_col' ? "the year of publication" : "the complexity of a game", "the average rating", corr
        }
    }'
}

# Correlation 1: Year Published vs Rating Average
correlation $year_col $rating_col

# Correlation 2: Complexity Average vs Rating Average
correlation $complexity_col $rating_col
