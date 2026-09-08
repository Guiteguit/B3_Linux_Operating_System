#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"
require_root

echo 'B3 Linux Validator — TP02'
echo '----------------------------------------'

for grp in developers operations audit; do
  getent group "$grp" >/dev/null && pass "groupe présent: $grp" || fail "groupe absent: $grp"
done

for user in alice bob charlie; do
  id "$user" >/dev/null 2>&1 && pass "utilisateur présent: $user" || fail "utilisateur absent: $user"
done

id -nG alice 2>/dev/null | tr ' ' '\n' | grep -qx developers && pass 'alice membre de developers' || fail 'alice doit appartenir à developers'
id -nG bob 2>/dev/null | tr ' ' '\n' | grep -qx operations && pass 'bob membre de operations' || fail 'bob doit appartenir à operations'
id -nG charlie 2>/dev/null | tr ' ' '\n' | grep -qx audit && pass 'charlie membre de audit' || fail 'charlie doit appartenir à audit'

[[ -d /srv/company ]] && pass '/srv/company existe' || fail '/srv/company absent'
have getfacl && have setfacl && pass 'outils ACL installés' || fail 'paquet acl / commandes getfacl,setfacl manquants'

if [[ -d /srv/company && $(command -v getfacl || true) ]]; then
  ACL=$(getfacl -cp /srv/company 2>/dev/null || true)
  grep -Eq '^group:operations:rwx$' <<<"$ACL" && pass 'ACL operations = rwx' || fail 'ACL attendue: group:operations:rwx'
  grep -Eq '^group:audit:r-x$' <<<"$ACL" && pass 'ACL audit = r-x' || fail 'ACL attendue: group:audit:r-x'
  grep -Eq '^other::---$' <<<"$ACL" && pass 'others = ---' || fail 'others doivent être ---'

  # Tests fonctionnels.
  TESTFILE="/srv/company/.validator-alice-$$"
  if sudo -u alice bash -c "echo validator > '$TESTFILE'" 2>/dev/null; then
    pass 'alice peut écrire'
  else
    fail 'alice ne peut pas écrire'
  fi

  TESTFILE_BOB="/srv/company/.validator-bob-$$"
  if sudo -u bob bash -c "echo validator > '$TESTFILE_BOB'" 2>/dev/null; then
    pass 'bob peut écrire'
  else
    fail 'bob ne peut pas écrire'
  fi

  if [[ -f "$TESTFILE" ]] && sudo -u charlie cat "$TESTFILE" >/dev/null 2>&1; then
    pass 'charlie peut lire un fichier créé par alice'
  else
    fail 'charlie doit pouvoir lire un fichier créé par alice (vérifiez default ACL)'
  fi

  if sudo -u charlie touch "/srv/company/.validator-charlie-$$" 2>/dev/null; then
    fail 'charlie peut écrire alors que cela doit être refusé'
    rm -f "/srv/company/.validator-charlie-$$"
  else
    pass 'charlie ne peut pas écrire'
  fi

  # Default ACL = expert, mais nécessaire pour collaboration durable.
  grep -Eq '^default:group:operations:rwx$' <<<"$ACL" && bonus 'default ACL operations = rwx' || warn 'default ACL operations non trouvée'
  grep -Eq '^default:group:audit:r-x$' <<<"$ACL" && bonus 'default ACL audit = r-x' || warn 'default ACL audit non trouvée'
  grep -Eq '^default:other::---$' <<<"$ACL" && bonus 'default ACL others = ---' || warn 'default ACL other non trouvée'

  rm -f "$TESTFILE" "$TESTFILE_BOB" 2>/dev/null || true
fi

summary
