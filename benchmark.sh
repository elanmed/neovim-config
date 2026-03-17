#!/usr/bin/env bash
set -eu

RUNS=${1:-10}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FEATURE_COMPLETE="$SCRIPT_DIR/feature_complete.lua"
BAREBONES="$SCRIPT_DIR/barebones.lua"
STARTUPTIME_LOG=/tmp/nvim-startuptime.log

hyperfine \
  --warmup 2 \
  --runs "$RUNS" \
  -n "clean (baseline)" "nvim --headless --clean +qa 2>/dev/null" \
  -n "barebones.lua" "nvim --headless -u $BAREBONES +qa 2>/dev/null" \
  -n "feature_complete.lua" "nvim --headless -u $FEATURE_COMPLETE +qa 2>/dev/null"

rm -f "$STARTUPTIME_LOG"
nvim --headless -u "$FEATURE_COMPLETE" --startuptime "$STARTUPTIME_LOG" +qa 2>/dev/null

echo ""
echo "Top 20 slowest modules (feature_complete):"
grep "require(" "$STARTUPTIME_LOG" |
  awk '{print $3, $4}' |
  sort -n -r | head -20 || true

echo ""
echo "Raw log: $STARTUPTIME_LOG"
