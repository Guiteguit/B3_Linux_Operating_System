# TP08 — Sauvegarde, restauration et preuve de reprise

**Durée cible : 45 min — Niveau : 🟢 → 🟠 → 🔴**

## Contexte

NovaTech impose une sauvegarde locale des éléments critiques de `srv-linux01`.

Le but du TP n'est pas :

> « J'ai réussi à créer un `.tar.gz`. »

Le but est :

> **« Je sais restaurer une donnée supprimée et le prouver. »**

---

# Partie A — Périmètre 🟢

Sauvegardez :

```text
/etc/nginx
/srv/app
```

Destination :

```text
/backup
```

Avant toute chose :

```bash
sudo mkdir -p /backup
sudo chmod 700 /backup
```

Pourquoi un répertoire de sauvegarde ne devrait-il pas être librement accessible à tous les utilisateurs ?

---

# Partie B — Archive `tar` 🟢

Créez une archive datée :

```text
novatech-YYYYMMDD-HHMMSS.tar.gz
```

Puis **listez son contenu sans l'extraire**.

Vous devez vérifier que les deux périmètres attendus sont présents.

---

# Partie C — Copie synchronisée avec `rsync` 🟢

Synchronisez `/srv/app/` vers :

```text
/backup/srv-app/
```

Question :

> `tar` et `rsync` répondent-ils exactement au même besoin ?

---

# Partie D — Test de restauration obligatoire 🟠

Créez :

```text
/srv/app/BACKUP_RESTORE_PROOF
```

avec exactement :

```text
B3_RESTORE_OK
```

Puis :

1. sauvegardez ;
2. calculez le SHA-256 du fichier ;
3. supprimez le fichier source ;
4. restaurez-le depuis **l'archive** ;
5. recalculez le SHA-256 ;
6. comparez les deux valeurs.

Le fichier final doit à nouveau se trouver dans :

```text
/srv/app/BACKUP_RESTORE_PROOF
```

---

# Partie E — Script de sauvegarde 🟠

Créez :

```text
/usr/local/sbin/novatech-backup.sh
```

Le script doit :

- créer `/backup` si nécessaire ;
- produire une archive horodatée ;
- synchroniser `/srv/app/` avec `rsync` ;
- écrire dans `/var/log/novatech/backup.log` ;
- retourner `0` si tout réussit ;
- retourner un code non nul en cas d'erreur.

Copiez aussi ce script dans :

```text
livrables/tp08/backup.sh
```

---

# Partie F — Rétention 🔴

Ajoutez une rétention simple :

> conserver les archives NovaTech pendant **7 jours** puis supprimer les plus anciennes.

Ne supprimez que les fichiers correspondant précisément au motif de vos sauvegardes NovaTech.

Question : pourquoi un `find ... -delete` trop large est-il dangereux ?

---

## Validation automatique

```bash
sudo ./scripts/checks/check-tp08.sh
```

---

## Livrables

```text
livrables/tp08/backup.sh
livrables/tp08/restauration.txt
```

`restauration.txt` :

```text
Archive utilisée :
SHA256 avant suppression :
SHA256 après restauration :
Résultat comparaison :
Commandes de restauration utilisées :
```

## Question de débrief

Pourquoi une sauvegarde jamais restaurée n'est-elle qu'une **hypothèse de sauvegarde** ?
