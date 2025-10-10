#!/usr/bin/env bash
set -euo pipefail

# ─── 1. Determine batch flag by OS ────────────────────────────────────────
if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
  export STATA_FLAG="-b"  # Default to batch mode for Linux and macOS
else
  export STATA_FLAG="-e"  # Default to interactive mode for Windows
fi

# ─── 2. Ask user which edition ───────────────────────────────────────────
read -rp "Which Stata edition? [SE/MP]: " ED
ED="${ED^^}"   # uppercase
if [[ "$ED" != "SE" && "$ED" != "MP" ]]; then
  echo "Please enter exactly SE or MP." >&2
  echo "Press Enter to exit..."
  read
  exit 1
fi

# ─── 3. Build exe name & locate it ────────────────────────────────────────
# Windoes
if [[ "$STATA_FLAG" == "-e" ]]; then
  EXE_NAME="Stata${ED}-64.exe"
  if command -v "$EXE_NAME" &>/dev/null; then
    export STATA_EXE="$(command -v "$EXE_NAME")"
  elif [[ -x "/c/Program Files/Stata18/$EXE_NAME" ]]; then
    export STATA_EXE="/c/Program Files/Stata18/$EXE_NAME"
  else
    echo "Error: $EXE_NAME not found in PATH or default location." >&2
    echo "Press Enter to exit..."
    read
    exit 1
  fi
# Linux/macOS
elif [[ "$STATA_FLAG" == "-b" ]]; then
  EXE_NAME="stata-${ED,,}"
  if command -v "$EXE_NAME" &>/dev/null; then
    export STATA_EXE="$(command -v "$EXE_NAME")"
  elif command -v "stata" &>/dev/null; then
    export STATA_EXE="$(command -v stata)"
  else
    echo "Error: $EXE_NAME not found in PATH or default location." >&2
    echo "Press Enter to exit..."
    read
    exit 1
  fi

fi

# ─── 4. Invoke the correct runner ────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
chmod 700 "$SCRIPT_DIR/${ED}.sh"
exec "$SCRIPT_DIR/${ED}.sh"

# To run the script, open a terminal and type the following commands: ########################################################
#   cd "C:/Users/ble10/Dropbox/Monte_Carlo/Windows/analysis"
#   chmod 700 1.run_do_files.sh
#   ./1.run_do_files.sh
