#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
source "$SCRIPT_DIR/_lib.sh"

require_root

echo 'B3 Linux Validator — TP00'
echo '----------------------------------------'

[[ "$(hostname)" == "srv-linux01" ]] && pass 'hostname = srv-linux01' || fail "hostname attendu: srv-linux01 (actuel: $(hostname))"

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] && pass 'distribution Ubuntu' || fail "distribution attendue: Ubuntu (actuelle: ${ID:-inconnue})"
  [[ "${VERSION_ID:-}" == "24.04" ]] && pass 'version Ubuntu 24.04' || warn "version attendue pour le lab: 24.04 (actuelle: ${VERSION_ID:-inconnue})"
else
  fail '/etc/os-release introuvable'
fi

[[ -n "$(uname -r)" ]] && pass "kernel détecté: $(uname -r)" || fail 'kernel non détecté'
[[ -n "${SUDO_USER:-}" ]] && pass "sudo fonctionnel pour ${SUDO_USER}" || warn 'lancez idéalement ce script via sudo depuis votre compte nominatif'

for cmd in git curl vim tree jq lsof dig ip; do
  have "$cmd" && pass "outil présent: $cmd" || fail "outil manquant: $cmd"
done

ip route show default | grep -q '^default ' && pass 'route par défaut présente' || fail 'aucune route par défaut détectée'

if getent hosts github.com >/dev/null 2>&1; then
  pass 'résolution DNS fonctionnelle pour github.com'
else
  warn 'résolution github.com non confirmée (filtrage réseau possible)'
fi

# Au moins deux block devices de type disk.
DISK_COUNT=$(lsblk -dn -o TYPE 2>/dev/null | awk '$1=="disk"{n++} END{print n+0}')
(( DISK_COUNT >= 2 )) && pass "au moins deux disques détectés ($DISK_COUNT)" || fail "second disque data non détecté (disques: $DISK_COUNT)"

# Cherche au moins un disque sans point de montage direct et sans filesystem direct, hors premier disque.
RAW_DISKS=$(lsblk -dn -o NAME,TYPE,FSTYPE,MOUNTPOINTS 2>/dev/null | awk '$2=="disk" && $3=="" && $4==""{print $1}')
[[ -n "$RAW_DISKS" ]] && pass "disque(s) brut(s) candidat(s): $RAW_DISKS" || warn 'aucun disque brut évident détecté; vérifiez manuellement lsblk avant TP04'

summary
