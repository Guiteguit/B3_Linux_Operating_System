#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"
require_root

echo 'B3 Linux Validator — TP08'
echo '----------------------------------------'

BACKUP=/backup
SCRIPT=/usr/local/sbin/novatech-backup.sh
PROOF=/srv/app/BACKUP_RESTORE_PROOF

[[ -d "$BACKUP" ]] && pass '/backup existe' || fail '/backup absent'
if [[ -d "$BACKUP" ]]; then
  MODE=$(stat -c '%a' "$BACKUP" 2>/dev/null || echo '?')
  [[ "$MODE" == '700' ]] && pass '/backup permissions = 700' || warn "/backup permissions = $MODE (700 recommandé pour le TP)"
fi

ARCHIVE=$(find "$BACKUP" -maxdepth 1 -type f -name 'novatech-*.tar.gz' -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2-)
if [[ -n "$ARCHIVE" && -f "$ARCHIVE" ]]; then
  pass "archive NovaTech détectée: $(basename "$ARCHIVE")"
  if tar -tzf "$ARCHIVE" 2>/dev/null | grep -Eq '(^|/)etc/nginx|^etc/nginx'; then pass 'archive contient /etc/nginx'; else fail 'archive ne semble pas contenir /etc/nginx'; fi
  if tar -tzf "$ARCHIVE" 2>/dev/null | grep -Eq '(^|/)srv/app|^srv/app'; then pass 'archive contient /srv/app'; else fail 'archive ne semble pas contenir /srv/app'; fi
else
  fail 'aucune archive /backup/novatech-*.tar.gz détectée'
fi

[[ -d /backup/srv-app ]] && pass 'copie rsync /backup/srv-app présente' || fail '/backup/srv-app absent'

if [[ -f "$PROOF" ]] && grep -qx 'B3_RESTORE_OK' "$PROOF"; then
  pass 'preuve de restauration présente et correcte'
else
  fail 'preuve /srv/app/BACKUP_RESTORE_PROOF absente ou incorrecte'
fi

if [[ -f "$SCRIPT" ]]; then
  pass 'novatech-backup.sh présent'
  [[ -x "$SCRIPT" ]] && pass 'script de backup exécutable' || fail 'script de backup non exécutable'
  bash -n "$SCRIPT" >/tmp/b3-tp08-bashn.out 2>&1 && pass 'syntaxe Bash valide' || fail 'syntaxe Bash invalide'
  grep -Eq 'tar[[:space:]]' "$SCRIPT" && pass 'tar utilisé dans le script' || fail 'tar non détecté dans le script'
  grep -Eq 'rsync[[:space:]]' "$SCRIPT" && pass 'rsync utilisé dans le script' || fail 'rsync non détecté dans le script'
  grep -Eq '/var/log/novatech/backup\.log' "$SCRIPT" && pass 'journalisation backup.log détectée' || warn 'backup.log non détecté dans le script'
  grep -Eq 'find .*novatech-|mtime|mmin' "$SCRIPT" && bonus 'challenge rétention détecté' || true
else
  fail "$SCRIPT absent"
fi

[[ -s /var/log/novatech/backup.log ]] && pass 'backup.log contient des données' || warn 'backup.log absent ou vide'

summary
