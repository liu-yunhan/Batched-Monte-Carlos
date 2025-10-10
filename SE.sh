#!/usr/bin/env bash
set -euo pipefail

### ── Common Setup (in both SE.sh & MP.sh) ────────────────────────────────
ROOT_DIR="$(pwd)"
DO_FILES_DIR="$ROOT_DIR/generated_dofiles"
PARENT_DIR="$(dirname "$ROOT_DIR")"
DTA_FILES_DIR="$ROOT_DIR/Outputs"
DONE_FILES_DIR="$ROOT_DIR/done_dofiles"
LOG_DIR="$ROOT_DIR/logs"

# prepare dirs
mkdir -p "$LOG_DIR" "$DONE_FILES_DIR"

# discover batches
declare -A seen
batches=()
for f in "$DO_FILES_DIR"/*.do; do
  b=$(basename "$f" .do)
  suffix=${b##*_}
  if [[ -n "$suffix" && -z "${seen[$suffix]:-}" ]]; then
    seen[$suffix]=1
    batches+=("$suffix")
  fi
done
mapfile -t batches < <(printf '%s\n' "${batches[@]}" | sort -V)

# ensure logs go into $LOG_DIR
cd "$LOG_DIR"

### ── Detect OS and get total logical cores ───────────────────────────────
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    TOTAL_CORES=$(nproc)
elif [[ "$OSTYPE" == "darwin"* ]]; then
    TOTAL_CORES=$(sysctl -n hw.ncpu)
else
    # Windows under Git-Bash/WSL: invoke PowerShell
    TOTAL_CORES=$(powershell.exe -Command \
      "(Get-WmiObject Win32_ComputerSystem).NumberOfLogicalProcessors" 2>/dev/null)
fi
NUM_CORES=$(( TOTAL_CORES - 2 ))    # Reserve 2 cores for system
(( NUM_CORES < 1 )) && NUM_CORES=1  # ensure at least 1 remains for Stata
echo "Total CPU threads detected: $TOTAL_CORES"
echo "Running up to $NUM_CORES jobs in parallel."

### ── Parallel Execution Loop ────────────────────────────────────────────
process_do() {
  local file="$1"
  local name
  name=$(basename "$file" .do)
  echo "Running $name…"
  "$STATA_EXE" $STATA_FLAG do "$file"
  if [[ -f "$DTA_FILES_DIR/$name.dta" ]]; then
    mv "$file" "$DONE_FILES_DIR/"
    echo "→ moved $name.do"
  fi
}

export -f process_do
export DTA_FILES_DIR DONE_FILES_DIR STATA_EXE STATA_FLAG

for batch in "${batches[@]}"; do
  echo "=== Batch $batch ==="
  # Launch each .do in background, up to $NUM_CORES jobs at once
  for file in "$DO_FILES_DIR"/*_"$batch".do; do
    process_do "$file" &
    # throttle
    while (( $(jobs -rp | wc -l) >= NUM_CORES )); do
      wait -n
    done
  done
  # wait  # finish remaining jobs before next batch
done

wait

echo "All done."


