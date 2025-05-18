#!/usr/bin/env bash
# analysis: Compute most popular mechanics/domains and Pearson correlations
# Usage: analysis <cleaned-file>

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <cleaned-file>" >&2
  exit 1
fi

file="$1"

# Determine column indices from header
read mech_col dom_col year_col rating_col comp_col < <(
  awk 'BEGIN{FS="\t"} NR==1{
    for(i=1;i<=NF;i++){
      if($i=="Mechanics") m=i
      if($i=="Domains") d=i
      if($i=="Year Published" || $i=="Year") y=i
      if($i=="Rating Average" || $i=="Average Rating") r=i
      if($i=="Complexity Average" || $i=="Complexity") c=i
    }
    print m, d, y, r, c
    exit
  }' "$file"
)

# Most popular mechanics
awk -v FS="\t" -v col="$mech_col" '
NR>1 {
  n = split($col, arr, /,\s*/)
  for(i=1;i<=n;i++) {
    mech[arr[i]]++
    if(mech[arr[i]] > max_count) {
      max_count = mech[arr[i]]
      max_mech = arr[i]
    }
  }
}
END {
  printf "The most popular game mechanics is %s found in %d games\n", max_mech, max_count
}' "$file"

# Most popular domain
awk -v FS="\t" -v col="$dom_col" '
NR>1 {
  n = split($col, arr, /,\s*/)
  for(i=1;i<=n;i++) {
    dom[arr[i]]++
    if(dom[arr[i]] > max_count_dom) {
      max_count_dom = dom[arr[i]]
      max_dom = arr[i]
    }
  }
}
END {
  printf "The most popular game domain is %s found in %d games\n", max_dom, max_count_dom
}' "$file"

# Correlation: Year Published vs Rating Average
awk -v FS="\t" -v yc="$year_col" -v rc="$rating_col" '
NR>1 && $yc ~ /^[0-9]+$/ && $rc ~ /^[0-9]+(\.[0-9]+)?$/ {
  x = $yc
  y = $rc
  n++
  sumx += x
  sumy += y
  sumxy += x * y
  sumx2 += x * x
  sumy2 += y * y
}
END {
  num = n * sumxy - sumx * sumy
  den = sqrt((n * sumx2 - sumx^2) * (n * sumy2 - sumy^2))
  r = (den > 0 ? num / den : 0)
  printf "The correlation between the year of publication and the average rating is %.3f\n", r
}' "$file"

# Correlation: Complexity Average vs Rating Average
awk -v FS="\t" -v cc="$comp_col" -v rc="$rating_col" '
NR>1 && $cc ~ /^[0-9]+(\.[0-9]+)?$/ && $rc ~ /^[0-9]+(\.[0-9]+)?$/ {
  x = $cc
  y = $rc
  n++
  sumx += x
  sumy += y
  sumxy += x * y
  sumx2 += x * x
  sumy2 += y * y
}
END {
  num = n * sumxy - sumx * sumy
  den = sqrt((n * sumx2 - sumx^2) * (n * sumy2 - sumy^2))
  r = (den > 0 ? num / den : 0)
  printf "The correlation between the complexity of a game and its average rating is %.3f\n", r
}' "$file"
