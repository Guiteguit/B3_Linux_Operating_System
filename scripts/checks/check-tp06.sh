#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"
require_root

echo 'B3 Linux Validator — TP06'
echo '----------------------------------------'

HC=/usr/local/bin/novatech-healthcheck.sh
if [[ -f "$HC" ]]; then pass "$HC existe"; else fail "$HC absent"; summary; exit $?; fi
[[ -x "$HC" ]] && pass 'healthcheck exécutable' || fail 'healthcheck non exécutable'

bash -n "$HC" >/tmp/b3-tp06-bashn.out 2>&1 && pass 'syntaxe Bash valide' || fail 'syntaxe Bash invalide'

grep -Eq '^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*=' "$HC" && pass 'variables détectées' || fail 'aucune variable détectée'
grep -Eq '(^|[[:space:]])[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)[[:space:]]*\{' "$HC" && pass 'fonction Bash détectée' || fail 'aucune fonction Bash détectée'
grep -Eq '(^|[[:space:]])if([[:space:]]|$)' "$HC" && pass 'condition if détectée' || fail 'aucune condition if détectée'
grep -q '|' "$HC" && pass 'au moins un pipe détecté' || fail 'aucun pipe détecté'

grep -Eq 'df([[:space:]]|$)' "$HC" && pass 'contrôle filesystem détecté' || fail 'contrôle filesystem non détecté'
grep -Eq '(/proc/meminfo|free([[:space:]]|$))' "$HC" && pass 'contrôle mémoire détecté' || fail 'contrôle mémoire non détecté'
grep -Eq 'systemctl.*nginx|nginx.*systemctl' "$HC" && pass 'contrôle nginx détecté' || fail 'contrôle nginx non détecté'
grep -Eq 'ss .*80|:80' "$HC" && pass 'contrôle TCP/80 détecté' || fail 'contrôle TCP/80 non détecté'
grep -Eq 'curl .*127\.0\.0\.1|curl .*localhost|http://127\.0\.0\.1|http://localhost' "$HC" && pass 'contrôle HTTP local détecté' || fail 'contrôle HTTP local non détecté'
grep -Eq 'findmnt.*/srv/app|mountpoint.*/srv/app' "$HC" && pass 'contrôle /srv/app détecté' || fail 'contrôle /srv/app non détecté'

if OUT=$(timeout 15 "$HC" 2>&1); then
  RC=0
else
  RC=$?
fi
if (( RC == 0 || RC == 1 || RC == 2 )); then
  pass "code de retour valide: $RC"
else
  fail "code de retour attendu 0/1/2, reçu $RC"
fi

grep -Eq '\[(OK|WARNING|WARN|FAIL|CRITICAL)\]' <<<"$OUT" && pass 'sortie structurée avec états détectée' || warn 'sortie sans marqueurs [OK]/[WARNING]/[FAIL]'
grep -Eq 'RESULT:' <<<"$OUT" && pass 'ligne RESULT détectée' || warn 'ligne RESULT non détectée'

if JSON_OUT=$(timeout 15 "$HC" --json 2>/dev/null); then
  JSON_RC=0
else
  JSON_RC=$?
fi
if (( JSON_RC == 0 || JSON_RC == 1 || JSON_RC == 2 )) && grep -Eq '^\{.*\}$' <<<"$JSON_OUT"; then
  bonus 'mode --json détecté'
fi

summary
