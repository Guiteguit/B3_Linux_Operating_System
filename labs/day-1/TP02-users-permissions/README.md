# TP02 — Utilisateurs, groupes, permissions et ACL

**Durée cible : 1 h — Niveau : 🟢 → 🟠 → 🔴**

## Contexte

NovaTech souhaite mettre à disposition un espace partagé :

```text
/srv/company
```

Trois équipes doivent disposer de droits différents.

## Besoin métier

| Équipe | Droits attendus |
|---|---|
| `developers` | lecture + écriture |
| `operations` | lecture + écriture |
| `audit` | lecture seule |
| autres | aucun accès |

Utilisateurs :

```text
alice   → developers
bob     → operations
charlie → audit
```

> [!IMPORTANT]
> Sur un **répertoire**, le bit `x` signifie notamment « pouvoir traverser le répertoire ». Une équipe ayant besoin de lire les fichiers devra généralement avoir `r-x` sur le répertoire, même si elle ne doit rien y créer.

---

# Partie A — Comptes et groupes 🟢

## Étape 1 — Créer les groupes

Créez :

```text
developers
operations
audit
```

Commandes à explorer :

```bash
groupadd
getent group
```

## Étape 2 — Créer les utilisateurs

Créez `alice`, `bob` et `charlie` avec :

- un home directory ;
- `/bin/bash` comme shell ;
- le groupe demandé comme groupe/adhésion de travail.

Commandes possibles :

```bash
useradd
adduser
usermod
id
getent passwd
```

> Il existe plusieurs méthodes correctes. Vous devez être capable d'expliquer celle que vous avez choisie.

## Étape 3 — Observer l'architecture des comptes

Consultez **sans éditer manuellement** :

```text
/etc/passwd
/etc/group
/etc/shadow
```

Répondez :

1. à quoi servent UID et GID ?
2. où est stocké le hash du mot de passe ?
3. pourquoi `/etc/shadow` n'est-il pas lisible par un utilisateur standard ?
4. quel est le shell de `alice` ?

---

# Partie B — Permissions Unix classiques 🟢

Créez :

```text
/srv/company
```

Avant de toucher aux ACL, essayez de modéliser le besoin uniquement avec :

```bash
chown
chgrp
chmod
```

Répondez à cette question :

> **Peut-on représenter proprement developers=RW, operations=RW et audit=RO avec uniquement owner/group/other ?**

Ne cherchez pas immédiatement une commande : expliquez d'abord la limite du modèle classique.

### Vérification des bits sur un dossier

Pour un dossier, complétez :

```text
r =
w =
x =
```

---

# Partie C — ACL POSIX 🟠

Installez l'outil nécessaire :

```bash
sudo apt install -y acl
```

Découvrez :

```bash
getfacl
setfacl
```

Configurez `/srv/company` afin que :

```text
developers → rwx sur le répertoire
operations → rwx sur le répertoire
audit      → r-x sur le répertoire
others     → ---
```

> Le `x` donné à `audit` sur le **répertoire** permet la traversée. Il ne signifie pas que les fichiers de l'équipe audit doivent devenir exécutables.

Affichez le résultat avec :

```bash
getfacl /srv/company
```

### Tests réels obligatoires

Ne vous contentez jamais d'un `ls -l`. Testez réellement les identités.

Exemples :

```bash
sudo -u alice bash -c 'echo "created-by-alice" > /srv/company/alice.txt'
sudo -u bob bash -c 'echo "created-by-bob" > /srv/company/bob.txt'
sudo -u charlie cat /srv/company/alice.txt
sudo -u charlie touch /srv/company/charlie-should-fail.txt
```

Attendus :

```text
alice   : création OK
bob     : création OK
charlie : lecture OK
charlie : création REFUSÉE
```

---

# Partie D — Héritage des droits 🔴

Votre configuration fonctionne sur **le répertoire**. Mais NovaTech pose maintenant une nouvelle question :

> « Les fichiers créés demain par Alice seront-ils automatiquement lisibles par Bob et Charlie ? »

Testez avant de répondre.

Puis recherchez les **default ACL** et configurez l'héritage de manière à conserver le besoin métier pour les nouveaux fichiers et sous-répertoires.

Après configuration, créez un nouveau fichier avec `alice` et vérifiez son ACL.

---

## Validation automatique

```bash
sudo ./scripts/checks/check-tp02.sh
```

Le validateur effectue de vrais tests d'accès avec `alice`, `bob` et `charlie`.

---

## Livrable

Créez `livrables/tp02.txt` contenant :

```text
1. Sortie de id alice / bob / charlie
2. Permissions classiques de /srv/company
3. ACL de /srv/company
4. Default ACL de /srv/company
5. Résultats des tests d'accès
6. Explication : pourquoi les permissions classiques seules ne suffisaient pas ?
```

## ⭐ Bonus — SGID sur répertoire

Recherchez le rôle du bit **SGID lorsqu'il est positionné sur un répertoire**.

Expliquez en quoi il peut compléter une stratégie de collaboration par groupe, sans pour autant remplacer les ACL de ce TP.
