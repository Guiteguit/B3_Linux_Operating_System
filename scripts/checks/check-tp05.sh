#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"
require_root

echo 'B3 Linux Validator — TP05'
echo '----------------------------------------'

have ip && pass 'commande ip présente' || fail 'commande ip absente'
have ss && pass 'commande ss présente' || fail 'commande ss absente'

ip -4 addr show scope global | grep -q 'inet ' && pass 'adresse IPv4 globale détectée' || fail 'aucune IPv4 globale détectée'
ip route | grep -q '^default ' && pass 'route par défaut présente' || warn 'aucune route par défaut détectée'

if systemctl is-active --quiet ssh; then
  pass 'service SSH actif'
else
  fail 'service SSH inactif'
fi

ss -lntp 2>/dev/null | grep -Eq '[:.]22[[:space:]]' && pass 'TCP/22 en écoute' || fail 'TCP/22 non détecté en écoute'

SSHD_BIN=$(command -v sshd || true)
if [[ -n "$SSHD_BIN" ]]; then
  if "$SSHD_BIN" -t >/tmp/b3-tp05-sshd-test.out 2>&1; then
    pass 'configuration sshd syntaxiquement valide'
  else
    fail 'sshd -t signale une erreur (voir /tmp/b3-tp05-sshd-test.out)'
  fi
else
  fail 'sshd introuvable'
fi

if [[ -n "$SSHD_BIN" ]]; then
  EFFECTIVE=$($SSHD_BIN -T 2>/dev/null || true)
  if grep -qi '^permitrootlogin no$' <<<"$EFFECTIVE"; then
    pass 'PermitRootLogin effectif = no'
  else
    fail 'PermitRootLogin effectif doit être no'
  fi
  if grep -qi '^passwordauthentication no$' <<<"$EFFECTIVE"; then
    bonus 'challenge: PasswordAuthentication effectif = no'
  else
    warn 'authentification par mot de passe encore autorisée (challenge non réalisé)'
  fi
fi

# Présence d'au moins une clé authorized_keys chez un utilisateur humain.
KEY_FOUND=0
while IFS=: read -r user _ uid _ _ home shell; do
  if (( uid >= 1000 )) && [[ "$shell" != */nologin && "$shell" != */false ]]; then
    if [[ -s "$home/.ssh/authorized_keys" ]]; then
      KEY_FOUND=1
      break
    fi
  fi
done < /etc/passwd
(( KEY_FOUND == 1 )) && pass 'au moins un authorized_keys non vide détecté' || warn 'aucun authorized_keys non vide détecté chez les utilisateurs humains'

summary
