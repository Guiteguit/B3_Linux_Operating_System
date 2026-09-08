#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/_lib.sh"

DELIVERABLE="$ROOT/livrables/tp01.txt"

echo 'B3 Linux Validator — TP01'
echo '----------------------------------------'

PID1=$(ps -p 1 -o comm= 2>/dev/null | xargs || true)
[[ -n "$PID1" ]] && pass "PID 1 observé: $PID1" || fail 'impossible de déterminer PID 1'
[[ "$PID1" == "systemd" ]] && pass 'PID 1 = systemd sur ce lab' || warn "PID 1 n'est pas systemd ($PID1); environnement particulier ?"

[[ -r /proc/1/status ]] && pass '/proc/1 accessible' || fail '/proc/1/status non accessible'
ip route show default | grep -q '^default ' && pass 'route par défaut détectable' || fail 'route par défaut absente'

if [[ -f "$DELIVERABLE" ]]; then
  pass 'livrables/tp01.txt existe'
  for label in 'OS' 'Kernel' 'Architecture' 'CPU / vCPU' 'RAM totale' 'Disques' 'IPv4' 'Gateway' 'DNS' 'Uptime' 'PID 1' 'Commandes clés'; do
    grep -Fqi "$label" "$DELIVERABLE" && pass "champ présent: $label" || fail "champ manquant dans le livrable: $label"
  done
  LINES=$(grep -Ec '^[[:space:]]*-[[:space:]]+[^[:space:]]' "$DELIVERABLE" 2>/dev/null || true)
  (( LINES >= 3 )) && pass 'au moins trois commandes clés documentées' || warn 'documentez au moins trois commandes clés dans le livrable'
else
  fail 'livrables/tp01.txt absent'
fi

summary
