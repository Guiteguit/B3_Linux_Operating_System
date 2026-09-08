# Jour 1 — Construire et administrer `srv-linux01`

## Parcours

```text
TP00 Installation
      ↓
TP01 Discovery
      ↓
TP02 Users / Groups / ACL
      ↓
TP03 Processes / systemd / journal
      ↓
TP04 Storage / LVM / filesystem
```

| TP | Durée | Résultat attendu |
|---|---:|---|
| TP00 | 45 min | serveur installé et prêt |
| TP01 | 45 min | fiche d'identité du serveur |
| TP02 | 1 h | espace collaboratif avec droits réels |
| TP03 | 1 h | nginx + service systemd résilient |
| TP04 | 1 h 15 | stockage LVM persistant et extensible |

## Règle de validation

Après chaque TP, exécutez le validateur indiqué dans le support. À la fin de la journée :

```bash
sudo ./scripts/checks/check-all-day1.sh
```

Un `FAIL` doit être corrigé. Un `WARN` demande une vérification ou correspond parfois à un challenge non réalisé. Un `BONUS` valide un objectif avancé.
