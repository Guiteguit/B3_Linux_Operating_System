# TP03 — Processus, services, systemd et journal

**Durée cible : 1 h — Niveau : 🟢 → 🟠 → 🔴**

## Contexte

NovaTech doit publier une page Web interne sur `srv-linux01`, puis exécuter un petit agent maison comme service système.

L'objectif n'est pas seulement de savoir faire `systemctl restart` : vous devez apprendre à **observer l'état d'un service et ses logs avant d'agir**.

---

# Partie A — Nginx 🟢

## Étape 1 — Installer le service Web

```bash
sudo apt install -y nginx
```

Avant de modifier quoi que ce soit, observez :

```bash
systemctl status nginx
ps aux | grep '[n]ginx'
ss -lntp
curl -I http://127.0.0.1
```

Répondez :

- combien de processus nginx voyez-vous ?
- quel processus écoute sur TCP/80 ?
- quelle différence faites-vous entre un **processus** et un **service systemd** ?

## Étape 2 — Cycle de vie d'un service

Testez :

```bash
sudo systemctl stop nginx
systemctl status nginx

sudo systemctl start nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
systemctl is-enabled nginx
```

Expliquez la différence entre :

```text
start
restart
enable
```

## Étape 3 — Logs

```bash
journalctl -u nginx --no-pager -n 20
journalctl -u nginx --since "10 minutes ago"
```

> [!TIP]
> En incident, consultez l'état et les logs **avant** de redémarrer automatiquement le service. Un redémarrage peut masquer un symptôme utile au diagnostic.

---

# Partie B — Votre premier service systemd 🟢

## Étape 4 — Créer l'agent

Créez :

```text
/usr/local/bin/novatech-agent.sh
```

Contenu :

```bash
#!/usr/bin/env bash
set -u

while true; do
  echo "$(date -Is) novatech-agent alive pid=$$"
  sleep 10
done
```

Rendez-le exécutable.

Testez-le **manuellement quelques secondes**, puis arrêtez-le avec `Ctrl+C`.

Question : pourquoi tester un script manuellement avant de l'enfermer dans systemd ?

---

## Étape 5 — Créer l'unité systemd

Créez :

```text
/etc/systemd/system/novatech-agent.service
```

Votre unité doit au minimum contenir :

```ini
[Unit]
Description=NovaTech training agent
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/novatech-agent.sh

[Install]
WantedBy=multi-user.target
```

Puis :

```bash
sudo systemctl daemon-reload
sudo systemctl start novatech-agent
sudo systemctl enable novatech-agent
```

Observez :

```bash
systemctl status novatech-agent
journalctl -u novatech-agent -f
```

Quittez `journalctl -f` avec `Ctrl+C`.

---

# Partie C — Résilience 🟠

NovaTech exige maintenant :

> « Si l'agent plante, systemd doit le relancer automatiquement après quelques secondes. »

Ajoutez une politique de redémarrage adaptée.

Indices :

```text
Restart=
RestartSec=
```

Rechargez la configuration puis validez.

### Test obligatoire

1. récupérez le PID de l'agent ;
2. tuez brutalement **le processus de l'agent**, pas systemd ;
3. observez le nouveau PID ;
4. consultez le journal.

Expliquez pourquoi `systemctl stop novatech-agent` ne doit normalement pas provoquer la même réaction qu'un crash.

---

# Partie D — Moindre privilège 🔴

Pour l'instant, votre service s'exécute probablement avec l'identité par défaut de systemd.

Créez un compte système dédié :

```text
novatech
```

sans login interactif, puis faites fonctionner l'agent avec cette identité.

Objectif attendu :

```text
User=novatech
Group=novatech
```

### Bonus hardening

Si vous êtes en avance, recherchez et testez :

```ini
NoNewPrivileges=true
PrivateTmp=true
```

Vous devez expliquer ce que ces options changent avant de les conserver.

---

## Validation automatique

```bash
sudo ./scripts/checks/check-tp03.sh
```

---

## Livrable

`livrables/tp03.txt` doit contenir :

```text
PID nginx        :
Port nginx       :

Contenu novatech-agent.service :

PID agent avant crash :
PID agent après crash :

Restart policy   :
User du service  :
Commande logs    :
```

## Question de débrief

Expliquez avec vos mots la différence entre :

```text
systemctl start
systemctl enable
systemctl daemon-reload
```
