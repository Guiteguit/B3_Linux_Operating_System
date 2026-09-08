#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo 'Lancez ce script avec sudo.' >&2
  exit 2
fi

TOTAL_FAIL=0
for tp in 00 01 02 03 04; do
  echo
  echo "========================================"
  echo "TP$tp"
  echo "========================================"
  if "$SCRIPT_DIR/check-tp${tp}.sh"; then
    :
  else
    TOTAL_FAIL=$((TOTAL_FAIL+1))
  fi
done

echo
if (( TOTAL_FAIL == 0 )); then
  echo '🏆 JOUR 1 — VALIDATION TECHNIQUE COMPLETE'
  exit 0
else
  echo "❌ $TOTAL_FAIL TP(s) contiennent encore au moins un FAIL."
  exit 1
fi
