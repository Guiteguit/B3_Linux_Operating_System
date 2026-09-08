#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"
require_root

echo 'B3 Linux Validator — TP07'
echo '----------------------------------------'

LOG=/var/log/novatech/healthcheck.log
ROT=/etc/logrotate.d/novatech-healthcheck

[[ -d /var/log/novatech ]] && pass '/var/log/novatech existe' || fail '/var/log/novatech absent'
[[ -f "$LOG" ]] && pass 'healthcheck.log existe' || fail 'healthcheck.log absent'
[[ -s "$LOG" ]] && pass 'healthcheck.log contient des données' || warn 'healthcheck.log est vide'

SCHEDULED=0
if crontab -l 2>/dev/null | grep -q 'novatech-healthcheck'; then
  pass 'planification cron root détectée'
  SCHEDULED=1
fi
if grep -Rqs 'novatech-healthcheck' /etc/cron.d /etc/crontab 2>/dev/null; then
  pass 'planification cron système détectée'
  SCHEDULED=1
fi
if systemctl list-unit-files 2>/dev/null | grep -q '^novatech-healthcheck.timer'; then
  if systemctl is-enabled --quiet novatech-healthcheck.timer 2>/dev/null; then
    bonus 'systemd timer présent et activé'
  else
    warn 'systemd timer présent mais non activé'
  fi
  SCHEDULED=1
fi
(( SCHEDULED == 1 )) || fail 'aucune planification novatech-healthcheck détectée'

if [[ -f "$ROT" ]]; then
  pass 'configuration logrotate présente'
  grep -Eq '^[[:space:]]*daily([[:space:]]|$)' "$ROT" && pass 'rotation daily' || fail 'directive daily absente'
  grep -Eq '^[[:space:]]*rotate[[:space:]]+7([[:space:]]|$)' "$ROT" && pass '7 rotations conservées' || fail 'rotate 7 attendu'
  grep -Eq '^[[:space:]]*compress([[:space:]]|$)' "$ROT" && pass 'compression activée' || fail 'compress absent'
  grep -Eq '^[[:space:]]*missingok([[:space:]]|$)' "$ROT" && pass 'missingok présent' || fail 'missingok absent'
  grep -Eq '^[[:space:]]*notifempty([[:space:]]|$)' "$ROT" && pass 'notifempty présent' || fail 'notifempty absent'
  grep -Eq '^[[:space:]]*create([[:space:]]|$)' "$ROT" && pass 'recréation du log configurée' || warn 'directive create non détectée'
  if have logrotate && logrotate -d "$ROT" >/tmp/b3-tp07-logrotate-debug.out 2>&1; then
    pass 'logrotate accepte la configuration en mode debug'
  else
    fail 'logrotate signale une erreur (voir /tmp/b3-tp07-logrotate-debug.out)'
  fi
else
  fail "$ROT absent"
fi

summary
