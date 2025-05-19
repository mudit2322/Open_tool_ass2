# Board Game Data Analysis Toolkit

A set of robust Bash scripts for cleaning, inspecting, and analyzing board game data from a semicolon-separated CSV file.

---

## Contents

- [`preprocess.sh`](#1-preprocesssh) – Cleans and standardizes the raw CSV file for further processing  
- [`empty_cells.sh`](#2-empty_cellssh) – Detects and counts empty or missing data per column  
- [`analysis.sh`](#3-analysissh) – Computes statistical insights and correlations from the cleaned data

---

## 1. `preprocess.sh`

**Purpose:**  
Cleans a raw dataset by:
- Converting CRLF to LF line endings  
- Replacing semicolons with tabs  
- Converting decimal commas to dots (e.g., `3,14` → `3.14`)  
- Removing non-ASCII characters  
- Filling in missing `/ID` fields in the first column with unique sequential IDs

**Usage:**  
```bash
./preprocess.sh <input-file.csv> [output-file]
```
If `[output-file]` is omitted, output is sent to standard output.

---

## 2. `empty_cells.sh`

**Purpose:**  
Counts empty or whitespace-only values in each column of a cleaned TSV file.  
Warns if any row has a different number of columns than the header.

**Usage:**  
```bash
./empty_cells.sh <cleaned-file.tsv> <separator>
```
**Example (using tab as separator):**
```bash
./empty_cells.sh cleaned.tsv $'\t'
```

---

## 3. `analysis.sh`

**Purpose:**  
Performs data analysis on the cleaned dataset:
- Determines the most popular game mechanic
- Determines the most popular domain
- Calculates Pearson correlation between Year Published and Average Rating
- Calculates Pearson correlation between Complexity and Average Rating

**Usage:**  
```bash
./analysis.sh <cleaned-file.tsv>
```

**Example:**  
```bash
./analysis.sh cleaned.tsv
```

---

## Requirements & Notes

- All scripts are intended for use in a Unix-like shell environment (Linux, macOS, or WSL).
- Input files should be in the expected format as described above.
- Ensure scripts have executable permissions:  
  ```bash
  chmod +x preprocess.sh empty_cells.sh analysis.sh
  ```
- If you encounter `/usr/bin/env: 'bash\r': No such file or directory`, convert scripts to Unix line endings using `dos2unix <scriptname>` or `sed -i 's/\r$//' <scriptname>`.
- The scripts do not fully support quoted CSV fields with embedded semicolons or commas; for complex CSVs, consider preprocessing with a CSV-aware tool.

---

## Example Workflow

```bash
# Clean the raw CSV
./preprocess.sh raw_games.csv > cleaned.tsv

# Check for empty cells
./empty_cells.sh cleaned.tsv $'\t'

# Analyze the cleaned data
./analysis.sh cleaned.tsv
```

---

## Author

Mudit Mamgain (23931717)