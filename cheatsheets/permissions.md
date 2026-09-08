# Cheat sheet — permissions Linux

```text
-rwxr-x---
 ||| ||| |||
  u   g   o
```

| Permission | Valeur | Fichier | Répertoire |
|---|---:|---|---|
| r | 4 | lire | lister |
| w | 2 | modifier | créer/supprimer |
| x | 1 | exécuter | traverser |

Exemple : `chmod 750 script.sh` → `rwxr-x---`

ACL : `getfacl`, `setfacl`.
