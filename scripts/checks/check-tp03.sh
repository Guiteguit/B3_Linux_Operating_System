#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"
require_root

echo 'B3 Linux Validator — TP03'
echo '----------------------------------------'

systemctl is-active --quiet nginx && pass 'nginx actif' || fail 'nginx doit être actif'
systemctl is-enabled --quiet nginx && pass 'nginx activé au boot' || fail 'nginx doit être enabled'
ss -lnt 2>/dev/null | awk '{print $4}' | grep -Eq '(^|:)80$' && pass 'TCP/80 en écoute' || fail 'aucune écoute TCP/80 détectée'
curl -fsS --max-time 3 http://127.0.0.1 >/dev/null 2>&1 && pass 'HTTP local répond' || fail 'curl http://127.0.0.1 échoue'

[[ -x /usr/local/bin/novatech-agent.sh ]] && pass 'novatech-agent.sh exécutable' || fail 'script absent ou non exécutable'
[[ -f /etc/systemd/system/novatech-agent.service ]] && pass 'unité novatech-agent.service présente' || fail 'unité systemd absente'
systemctl is-active --quiet novatech-agent && pass 'novatech-agent actif' || fail 'novatech-agent doit être actif'
systemctl is-enabled --quiet novatech-agent && pass 'novatech-agent activé au boot' || fail 'novatech-agent doit être enabled'

RESTART=$(systemctl show novatech-agent -p Restart --value 2>/dev/null || true)
[[ "$RESTART" == "on-failure" || "$RESTART" == "always" ]] && pass "politique de restart configurée: $RESTART" || fail "Restart attendu on-failure/always (actuel: ${RESTART:-inconnu})"

RESTART_USEC=$(systemctl show novatech-agent -p RestartUSec --value 2>/dev/null || true)
[[ -n "$RESTART_USEC" && "$RESTART_USEC" != "0" ]] && pass "délai de restart configuré: $RESTART_USEC" || warn 'RestartSec semble nul/non défini'

SERVICE_USER=$(systemctl show novatech-agent -p User --value 2>/dev/null || true)
if [[ "$SERVICE_USER" == "novatech" ]]; then
  bonus 'service exécuté avec User=novatech'
  id novatech >/dev/null 2>&1 && bonus 'compte système novatech présent' || warn 'User=novatech configuré mais compte introuvable'
else
  warn "bonus moindre privilège non validé (User=${SERVICE_USER:-root/default})"
fi

NNP=$(systemctl show novatech-agent -p NoNewPrivileges --value 2>/dev/null || true)
[[ "$NNP" == "yes" ]] && bonus 'NoNewPrivileges=true' || true

summary
