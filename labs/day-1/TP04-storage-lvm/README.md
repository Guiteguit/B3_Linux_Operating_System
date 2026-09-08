# TP04 — Stockage, filesystem, montage et LVM

**Durée cible : 1 h 15 — Niveau : 🟢 → 🟠 → 🔴**

## Contexte

L'application NovaTech a besoin d'un espace de données séparé du système, persistant après reboot et extensible sans recréer le serveur.

## Architecture cible

```text
SECOND DISK
    │
    ▼
Physical Volume (PV)
    │
    ▼
VG_DATA
    │
    ▼
LV_APP (2 GiB puis ≥ 3 GiB)
    │
    ▼
ext4 filesystem
    │
    ▼
/srv/app
```

> [!CAUTION]
> Les commandes de stockage peuvent détruire des données. **Identifiez le bon disque avant toute écriture.** Ne recopiez jamais aveuglément un nom de device venant du voisin ou du support.

---

# Partie A — Observer avant d'agir 🟢

## Étape 1 — Identifier le second disque

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
sudo blkid
```

Notez le disque système et le disque data dans votre livrable.

Questions :

- quelle différence entre un **disque**, une **partition**, un **filesystem** et un **point de montage** ?
- le disque data possède-t-il déjà un filesystem ?

Ne continuez que lorsque vous êtes certain du bon device.

---

# Partie B — Construire LVM 🟢

## Étape 2 — Installer LVM

```bash
sudo apt install -y lvm2
```

## Étape 3 — Physical Volume

Transformez le **second disque** en PV.

Commandes à étudier :

```bash
pvcreate
pvs
pvdisplay
```

## Étape 4 — Volume Group

Créez :

```text
VG_DATA
```

Puis vérifiez :

```bash
vgs
```

## Étape 5 — Logical Volume

Créez :

```text
LV_APP
```

avec une taille initiale de **2 GiB**.

Vérifiez :

```bash
lvs
lsblk
```

À ce stade, répondez :

> Le Logical Volume est-il déjà utilisable comme répertoire Linux ? Pourquoi ?

---

# Partie C — Filesystem et montage 🟢

## Étape 6 — Créer un filesystem ext4

Créez un filesystem `ext4` sur le LV.

Puis créez :

```text
/srv/app
```

et montez-y le filesystem.

Vérifiez avec **deux visions différentes** :

```bash
lsblk -f
df -hT
findmnt /srv/app
```

Expliquez ce que chacune vous apprend.

---

## Étape 7 — Rendre le montage persistant

Le montage manuel disparaîtrait après reboot.

Ajoutez une entrée correcte dans :

```text
/etc/fstab
```

Pour ce TP, utilisez l'**UUID du filesystem**.

Vous pouvez l'obtenir avec :

```bash
sudo blkid
```

### Test obligatoire avant tout reboot

```bash
sudo umount /srv/app
sudo mount -a
findmnt /srv/app
```

> [!IMPORTANT]
> Un `mount -a` qui retourne une erreur signifie que votre `/etc/fstab` doit être corrigé **avant de redémarrer la machine**.

---

# Partie D — Extension sans perte de données 🟠

Créez d'abord un témoin :

```bash
sudo sh -c 'echo "NovaTech persistent data" > /srv/app/DO_NOT_LOSE_ME'
```

Notez :

```bash
sudo lvs
sudo df -hT /srv/app
```

## Étape 8 — Agrandir seulement le LV

Agrandissez `LV_APP` d'au moins **1 GiB**, mais dans un premier temps **n'agrandissez pas automatiquement le filesystem**.

Puis comparez :

```bash
sudo lvs
sudo df -hT /srv/app
```

### Question piège

> Le LV a grandi. Pourquoi `df` peut-il encore afficher presque la même taille ?

Vous devez arriver à la conclusion :

```text
Taille du LV ≠ taille du filesystem
```

## Étape 9 — Agrandir le filesystem

Agrandissez maintenant le filesystem ext4 afin qu'il utilise l'espace supplémentaire.

Vérifiez :

```bash
sudo lvs
sudo df -hT /srv/app
cat /srv/app/DO_NOT_LOSE_ME
```

Le fichier doit toujours être présent.

---

# Partie E — Méthode alternative 🔴

Recherchez une option LVM permettant, lors d'une future extension, d'agrandir **le LV et le filesystem dans la même opération**.

Ne l'utilisez pas tant que vous ne pouvez pas expliquer ce qu'elle automatise.

---

## Validation automatique

```bash
sudo ./scripts/checks/check-tp04.sh
```

Le score distingue :

- la construction LVM de base ;
- le montage persistant ;
- le challenge d'extension ;
- la conservation des données.

---

## Livrable

Créez `livrables/tp04.txt` :

```text
Disque système :
Disque data    :

--- AVANT EXTENSION ---
pvs :
vgs :
lvs :
df -hT /srv/app :

--- FSTAB ---
Ligne /srv/app :

--- APRÈS EXTENSION DU LV, AVANT RESIZE FS ---
lvs :
df -hT /srv/app :
Explication :

--- APRÈS RESIZE FS ---
lvs :
df -hT /srv/app :
DO_NOT_LOSE_ME :
```

## Question de débrief

Remettez dans l'ordre et expliquez chaque couche :

```text
mount point / filesystem / LV / VG / PV / disk
```
