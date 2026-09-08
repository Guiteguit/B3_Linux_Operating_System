# TP06 — Bash : automatiser un healthcheck

**Durée cible : 1 h 15 — Niveau : 🟢 → 🟠 → 🔴**

## Contexte

L'équipe Ops veut une commande capable de répondre à une question simple :

> **« Le serveur est-il sain maintenant ? »**

Vous allez écrire un mini outil de supervision local, pas un simple enchaînement de `echo`.

---

# Partie A — Spécification 🟢

Créez :

```text
/usr/local/bin/novatech-healthcheck.sh
```

Le script doit vérifier au minimum :

1. utilisation du filesystem `/` ;
2. mémoire disponible ;
3. état de `nginx` ;
4. écoute de TCP/80 ;
5. réponse HTTP locale ;
6. montage de `/srv/app`.

### Seuils

Placez les seuils en variables en début de script, par exemple :

```bash
DISK_WARNING=80
DISK_CRITICAL=90
MEM_WARNING_MB=500
```

Vous pouvez choisir vos valeurs, mais vous devez les justifier.

---

# Partie B — Format de sortie 🟢

Exemple sain :

```text
=== NovaTech Healthcheck ===
[OK]       Disk usage: 42%
[OK]       Memory available: 1870 MB
[OK]       nginx is active
[OK]       TCP/80 is listening
[OK]       HTTP responded with 200
[OK]       /srv/app is mounted
RESULT: OK
```

Exemple dégradé :

```text
[WARNING] Disk usage: 82%
[FAIL]    nginx is inactive
RESULT: CRITICAL
```

Votre script doit contenir au minimum :

```text
variables
fonctions
conditions if
au moins un pipe
un code de retour
```

---

# Partie C — Codes de retour 🟠

Utilisez :

```text
0 = OK
1 = WARNING
2 = CRITICAL
```

Le code final doit représenter **l'état le plus grave rencontré**.

Exemples :

```text
Tous les contrôles OK                  → 0
Disk WARNING, le reste OK              → 1
Disk WARNING + nginx DOWN              → 2
```

Testez systématiquement :

```bash
/usr/local/bin/novatech-healthcheck.sh
echo $?
```

### Attention à `set -e`

Un healthcheck **s'attend** à rencontrer des commandes pouvant échouer. Si vous utilisez `set -e`, soyez capable d'expliquer pourquoi ce comportement peut être gênant ici.

---

# Partie D — Tester son outil 🟠

Ne vous contentez pas du cas où tout fonctionne.

Avec le formateur ou sur votre VM :

1. observez le résultat normal ;
2. arrêtez nginx ;
3. relancez le healthcheck ;
4. vérifiez le message et le code retour ;
5. remettez nginx en état ;
6. testez à nouveau.

**Votre outil doit détecter le problème, pas le corriger.**

---

# Partie E — Mode machine 🔴

Ajoutez un mode :

```bash
novatech-healthcheck.sh --json
```

Exemple minimal :

```json
{"status":"OK","exit_code":0}
```

Bonus supplémentaires possibles :

- load average ;
- temps de réponse HTTP ;
- espace libre de `/srv/app` ;
- nombre de mises à jour de sécurité en attente.

---

## Validation automatique

```bash
sudo ./scripts/checks/check-tp06.sh
```

Le validateur vérifie la structure et exécute le script **sans modifier le serveur**.

---

## Livrable

```text
livrables/tp06/novatech-healthcheck.sh
livrables/tp06/README.md
```

Le `README.md` doit expliquer :

```text
contrôles réalisés
seuils choisis
codes de retour
un cas de panne testé
ce que vous amélioreriez en production
```

## Question de débrief

Pourquoi un script de supervision doit-il séparer :

```text
observation
≠
remédiation
```
