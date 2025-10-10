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

### ── Execution Loop ──────────────────────────────────────────────────────
for batch in "${batches[@]}"; do
  echo "=== Batch $batch ==="
  for file in "$DO_FILES_DIR"/*_"$batch".do; do
    name=$(basename "$file" .do)
    echo "Running $name…"
    "$STATA_EXE" $STATA_FLAG do "$file"
    if [[ -f "$DTA_FILES_DIR/$name.dta" ]]; then
      mv "$file" "$DONE_FILES_DIR/"
      echo "→ moved $name.do"
    fi
  done
done

echo "All done."
