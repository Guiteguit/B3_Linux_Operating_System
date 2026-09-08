#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FAIL=0
for n in 05 06 07 08; do
  echo
  echo "========================================"
  echo "TP$n"
  echo "========================================"
  if ! sudo "$SCRIPT_DIR/check-tp${n}.sh"; then
    FAIL=1
  fi
done

exit "$FAIL"
