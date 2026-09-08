#!/usr/bin/env bash
set -uo pipefail

PASS=0
FAIL=0
WARN=0
BONUS=0

pass() { printf '[PASS] %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '[FAIL] %s\n' "$1"; FAIL=$((FAIL+1)); }
warn() { printf '[WARN] %s\n' "$1"; WARN=$((WARN+1)); }
bonus() { printf '[BONUS] %s\n' "$1"; BONUS=$((BONUS+1)); }

have() { command -v "$1" >/dev/null 2>&1; }

require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "Ce validateur doit être lancé avec sudo." >&2
    exit 2
  fi
}

summary() {
  echo
  echo '----------------------------------------'
  printf 'PASS=%d  FAIL=%d  WARN=%d  BONUS=%d\n' "$PASS" "$FAIL" "$WARN" "$BONUS"
  if (( FAIL == 0 )); then
    echo '✅ Validation technique réussie.'
    return 0
  else
    echo '❌ Des éléments obligatoires restent à corriger.'
    return 1
  fi
}
