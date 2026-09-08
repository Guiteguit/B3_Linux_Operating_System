# TP07 — Logs, planification et rotation

**Durée cible : 45 min — Niveau : 🟢 → 🟠 → 🔴**

## Contexte

Le healthcheck fonctionne. NovaTech veut désormais :

```text
l'exécuter automatiquement
+
conserver un historique
+
empêcher les logs de remplir le disque
```

---

# Partie A — Journaliser 🟢

Créez :

```text
/var/log/novatech/
/var/log/novatech/healthcheck.log
```

Choisissez des permissions cohérentes.

Testez une exécution manuelle :

```bash
sudo /usr/local/bin/novatech-healthcheck.sh \
  >> /var/log/novatech/healthcheck.log 2>&1
```

Expliquez `2>&1`.

---

# Partie B — Planifier 🟢

Planifiez une exécution toutes les **5 minutes**.

Vous pouvez utiliser :

```text
cron
```

Le job doit écrire stdout **et** stderr dans le log.

Après configuration, prouvez que la tâche est enregistrée.

> [!TIP]
> Pendant le TP, vous pouvez temporairement utiliser une fréquence plus courte pour observer une exécution, puis revenir à 5 minutes.

---

# Partie C — Rotation des logs 🟠

Créez :

```text
/etc/logrotate.d/novatech-healthcheck
```

La politique doit assurer :

- rotation `daily` ;
- conservation de 7 rotations ;
- compression ;
- tolérance si le fichier manque ;
- absence de rotation d'un fichier vide ;
- recréation du fichier avec des droits cohérents.

Avant de forcer une rotation, vérifiez la configuration en mode debug.

Puis réalisez une rotation de test et observez :

```text
healthcheck.log
healthcheck.log.1
...
```

---

# Partie D — systemd timer 🔴

Remplacez ou doublez temporairement cron par :

```text
novatech-healthcheck.service
novatech-healthcheck.timer
```

Le timer doit appeler le healthcheck et écrire dans le même log, directement ou via un wrapper.

Vous devez expliquer **au moins deux différences utiles** entre cron et un systemd timer.

Pistes :

```text
journal
état observable
unit dependencies
Persistent=true
OnCalendar=
```

---

## Validation automatique

```bash
sudo ./scripts/checks/check-tp07.sh
```

---

## Livrable

Créez `livrables/tp07.txt` :

```text
Méthode de planification : cron / systemd timer
Configuration planification :

Dernières lignes de /var/log/novatech/healthcheck.log :

Configuration logrotate :

Résultat du test logrotate :

Si timer utilisé :
systemctl list-timers :
```

## Question de débrief

Qu'est-ce qui arriverait à un serveur qui écrit des logs indéfiniment sans politique de rétention ?
