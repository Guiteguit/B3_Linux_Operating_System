#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"
require_root

echo 'B3 Linux Validator — TP04'
echo '----------------------------------------'

have pvs && have vgs && have lvs && pass 'outils LVM présents' || fail 'lvm2 manquant'

pvs --noheadings -o vg_name 2>/dev/null | xargs -n1 | grep -qx VG_DATA && pass 'PV rattaché à VG_DATA' || fail 'aucun PV associé à VG_DATA'
vgs VG_DATA >/dev/null 2>&1 && pass 'VG_DATA existe' || fail 'VG_DATA absent'
lvs VG_DATA/LV_APP >/dev/null 2>&1 && pass 'LV_APP existe' || fail 'LV_APP absent'

LVDEV="/dev/VG_DATA/LV_APP"
if [[ -b "$LVDEV" ]]; then
  pass "$LVDEV est un block device"
  FSTYPE=$(blkid -s TYPE -o value "$LVDEV" 2>/dev/null || true)
  [[ "$FSTYPE" == "ext4" ]] && pass 'filesystem ext4 présent' || fail "filesystem attendu ext4 (actuel: ${FSTYPE:-aucun})"
else
  fail "$LVDEV absent"
fi

if findmnt -rn /srv/app >/dev/null 2>&1; then
  pass '/srv/app monté'
  SRC=$(findmnt -rn -o SOURCE /srv/app 2>/dev/null || true)
  [[ "$SRC" == *"LV_APP"* || "$SRC" == *"VG_DATA"* ]] && pass "source de montage cohérente: $SRC" || warn "source de montage inattendue: $SRC"
else
  fail '/srv/app non monté'
fi

if grep -Eq '^[[:space:]]*UUID=[^[:space:]]+[[:space:]]+/srv/app[[:space:]]+ext4([[:space:]]|$)' /etc/fstab; then
  pass 'fstab utilise UUID pour /srv/app'
else
  fail 'entrée fstab UUID=... /srv/app ext4 attendue'
fi

# Vérifie que mount -a ne signale pas d'erreur.
if mount -a >/tmp/b3-tp04-mount-a.out 2>&1; then
  pass 'mount -a sans erreur'
else
  fail 'mount -a retourne une erreur (voir /tmp/b3-tp04-mount-a.out)'
fi

if [[ -b "$LVDEV" ]]; then
  LV_BYTES=$(blockdev --getsize64 "$LVDEV" 2>/dev/null || echo 0)
  LV_GIB=$(( LV_BYTES / 1024 / 1024 / 1024 ))
  if (( LV_BYTES >= 3 * 1024 * 1024 * 1024 )); then
    bonus "challenge: LV_APP >= 3 GiB (${LV_GIB} GiB approx.)"
  elif (( LV_BYTES >= 2 * 1024 * 1024 * 1024 )); then
    pass 'LV_APP >= 2 GiB (base)'
    warn 'challenge extension >= 3 GiB non validé'
  else
    fail 'LV_APP fait moins de 2 GiB'
  fi

  # Compare taille filesystem à la taille LV; tolérance large pour métadonnées.
  if findmnt -rn /srv/app >/dev/null 2>&1; then
    FS_BYTES=$(df -B1 --output=size /srv/app 2>/dev/null | tail -n1 | tr -d ' ' || echo 0)
    if (( LV_BYTES >= 3 * 1024 * 1024 * 1024 && FS_BYTES >= 2800 * 1024 * 1024 )); then
      bonus 'challenge: filesystem agrandi après extension du LV'
    fi
  fi
fi

if [[ -f /srv/app/DO_NOT_LOSE_ME ]]; then
  pass 'DO_NOT_LOSE_ME toujours présent'
  grep -q 'NovaTech persistent data' /srv/app/DO_NOT_LOSE_ME 2>/dev/null && bonus 'contenu de DO_NOT_LOSE_ME intact' || warn 'fichier présent mais contenu différent'
else
  warn 'DO_NOT_LOSE_ME absent (requis pour le challenge extension)'
fi

summary
