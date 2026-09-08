# Méthode de troubleshooting

Le cours utilise une méthode simple et répétable.

## 1. Reformuler le symptôme

Éviter :

> « Linux ne marche plus. »

Préférer :

> « `curl http://localhost` échoue alors que la VM répond au ping. »

## 2. Collecter des faits

Quelques familles d'outils :

```text
processus       → ps, top
services        → systemctl
logs            → journalctl, /var/log
réseau          → ip, ss, getent, curl
stockage        → lsblk, findmnt, df
permissions     → ls -l, id, getfacl
```

## 3. Formuler une hypothèse

L'hypothèse doit être testable.

## 4. Tester sans casser davantage

Lire l'état et les logs avant un redémarrage aveugle.

## 5. Corriger le minimum nécessaire

Éviter les modifications massives non justifiées.

## 6. Valider

Tester le service depuis le point de vue de l'utilisateur ou de l'application.

## 7. Documenter

Une mini-RCA doit contenir : cause, impact, correction et prévention.
