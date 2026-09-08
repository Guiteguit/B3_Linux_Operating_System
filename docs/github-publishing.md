# Publier ce dépôt sur GitHub

Nom de dépôt conseillé :

```text
b3-linux-sysadmin-bootcamp
```

Description conseillée :

```text
Bootcamp Linux SysAdmin B3 — Ubuntu, systemd, LVM, SSH, Bash, logs, backup et troubleshooting — 13 h de cours/TP.
```

Topics conseillés :

```text
linux ubuntu sysadmin systemd lvm ssh bash devops education lab troubleshooting
```

## Avec GitHub CLI

Depuis la racine du dépôt :

```bash
git init
git add .
git commit -m "feat: initial public release"
git branch -M main

gh repo create b3-linux-sysadmin-bootcamp \
  --public \
  --source=. \
  --remote=origin \
  --push
```

## Sans GitHub CLI

Créez un dépôt vide sur GitHub puis :

```bash
git init
git add .
git commit -m "feat: initial public release"
git branch -M main
git remote add origin <URL_DU_DEPOT_GITHUB>
git push -u origin main
```

## Réglages recommandés

- branche par défaut : `main` ;
- Issues : optionnelles ;
- Discussions : utiles si plusieurs promotions utilisent le support ;
- Wiki : inutile, la documentation est versionnée dans `docs/` ;
- dépôt étudiant : **public** ;
- dépôt formateur contenant corrections et incident injector : **privé**.
