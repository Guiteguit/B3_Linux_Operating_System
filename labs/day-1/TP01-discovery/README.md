# TP01 — Cartographier un serveur Linux

**Durée cible : 45 min — Niveau : 🟢 → 🟠 → 🔴**

## Contexte

Vous recevez un serveur que vous n'avez pas installé vous-même.

Avant toute modification, un administrateur doit répondre à une question simple :

> **« Qu'est-ce que j'ai réellement devant moi ? »**

Votre mission est de produire la fiche d'identité de `srv-linux01` **sans installer aucun nouvel outil**.

## Objectifs

- utiliser l'aide Linux plutôt qu'une liste de commandes à recopier ;
- retrouver les informations système essentielles ;
- utiliser pipes et redirections ;
- distinguer disque, partition, filesystem et montage ;
- observer les processus et comprendre le rôle du PID 1.

---

## Règles du TP

Vous pouvez utiliser :

```bash
man <commande>
<commande> --help
apropos <mot>
```

Contraintes :

- aucun nouveau paquet ne doit être installé ;
- vous devez utiliser **au moins deux pipes `|`** ;
- vous devez utiliser **au moins une redirection `>`** ;
- vous devez être capable d'expliquer vos commandes au formateur.

---

## Mission — Construire la fiche d'identité

Retrouvez :

1. distribution et version ;
2. version du kernel ;
3. architecture CPU ;
4. nombre de CPU/vCPU ;
5. mémoire totale et mémoire disponible ;
6. disques et partitions ;
7. filesystems actuellement montés ;
8. interfaces réseau ;
9. adresse IPv4 principale ;
10. route par défaut ;
11. mécanisme/résolveur DNS utilisé et DNS visibles ;
12. uptime ;
13. utilisateurs actuellement connectés ;
14. cinq processus consommant le plus de mémoire ;
15. PID 1 et nom du processus associé.

### Indices progressifs

<details>
<summary>Indice 1 — ressources</summary>
Cherchez les commandes relatives à CPU, mémoire et block devices. `apropos memory` peut vous aider.
</details>

<details>
<summary>Indice 2 — réseau</summary>
Vous avez déjà utilisé `ip` au TP00. Explorez ses sous-commandes et lisez également les fichiers/services liés à la résolution de noms.
</details>

<details>
<summary>Indice 3 — processus</summary>
La commande `ps` possède beaucoup d'options. Essayez de trier sa sortie plutôt que de lire des centaines de lignes.
</details>

---

## Mini-défi — `/proc`

Sans utiliser `uname`, trouvez la version du kernel via le pseudo-filesystem `/proc`.

Puis observez :

```bash
ls -ld /proc/1
```

Que représente `/proc/1` ?

---

## Livrable

Créez `livrables/tp01.txt` :

```text
OS             :
Kernel         :
Architecture   :
CPU / vCPU     :
RAM totale     :
RAM disponible :
Disques        :
Filesystems    :
IPv4           :
Gateway        :
DNS            :
Uptime         :
Users connectés:
Top RAM        :
PID 1          :

Commandes clés utilisées :
- `<commande 1>`
- `<commande 2>`
- `<commande 3>`
```

---

## Validation automatique

```bash
./scripts/checks/check-tp01.sh
```

Le validateur ne peut pas vérifier votre capacité à expliquer les résultats : le formateur pourra vous demander une commande au hasard.

---

## 🟠 Challenge — Pourquoi PID 1 est-il particulier ?

Expliquez :

- quel processus possède le PID 1 ;
- son rôle ;
- ce qui se passe lorsqu'un processus parent se termine et laisse un enfant orphelin ;
- pourquoi arrêter PID 1 n'est pas comparable à arrêter un processus applicatif classique.

## 🔴 Expert — Arbre des processus

Trouvez une commande permettant d'afficher l'arbre des processus.

Identifiez ensuite :

1. votre shell courant ;
2. son PID ;
3. son parent ;
4. le chemin permettant de remonter jusqu'au PID 1.
