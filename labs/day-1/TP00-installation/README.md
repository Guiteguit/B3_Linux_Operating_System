# TP00 — Installer et préparer `srv-linux01`

**Durée cible : 45 min — Niveau : 🟢 GUIDÉ**

> **Fil rouge NovaTech**
> Vous venez d'intégrer l'équipe Infrastructure. Une VM vierge vous est confiée. Ce serveur sera utilisé pendant tout le module : vous allez le construire aujourd'hui, l'exploiter demain… puis le dépanner lors de l'incident final.

## Objectifs

À la fin du TP, vous devez être capable de :

- installer une distribution Linux orientée serveur ;
- identifier **distribution**, **kernel** et **shell** ;
- configurer l'identité de base d'un serveur ;
- vérifier IP, route par défaut et résolution DNS ;
- mettre à jour le système avec le gestionnaire de paquets ;
- préparer un second disque qui sera utilisé plus tard pour LVM.

## Architecture attendue

```text
Nom            : srv-linux01
OS             : Ubuntu Server 24.04 LTS
CPU            : 2 vCPU
RAM            : 2 à 4 Go
Disque système : 20 Go minimum
Disque data    : 5 Go minimum, NON partitionné
Réseau         : DHCP autorisé pour le lab
SSH            : installé
```

> [!WARNING]
> Le second disque doit rester vierge. Il sera utilisé au TP04. Ne le formatez pas et ne le montez pas maintenant.

---

## Étape 1 — Installer Ubuntu Server

Pendant l'installation :

1. choisissez **Ubuntu Server 24.04 LTS** ;
2. utilisez `srv-linux01` comme hostname ;
3. créez un utilisateur nominatif ;
4. activez l'installation d'**OpenSSH Server** si l'option est proposée ;
5. n'utilisez que le disque système pour l'installation ;
6. laissez le disque data intact.

Lorsque la VM redémarre, connectez-vous avec votre utilisateur.

---

## Étape 2 — Identifier le système

Exécutez les commandes suivantes et comprenez ce qu'elles affichent :

```bash
hostnamectl
cat /etc/os-release
uname -r
echo "$SHELL"
```

Questions :

1. quelle commande vous donne la **distribution** ?
2. quelle commande vous donne la version du **kernel** ?
3. quelle commande vous indique le **shell** utilisé ?

---

## Étape 3 — Mettre le système à jour

```bash
sudo apt update
sudo apt upgrade -y
```

Avant de continuer, répondez à ces questions :

- quelle est la différence entre `apt update` et `apt upgrade` ?
- d'où viennent les paquets installés par `apt` ?

Vous pouvez explorer :

```bash
cat /etc/apt/sources.list 2>/dev/null
ls -l /etc/apt/sources.list.d/
```

---

## Étape 4 — Installer uniquement les outils de base

```bash
sudo apt install -y git curl vim tree jq lsof dnsutils
```

> Nous **n'installons pas `net-tools`** : pendant le module, vous utiliserez les outils modernes `ip` et `ss` plutôt que `ifconfig` et `netstat`.

Vérifiez quelques outils :

```bash
git --version
curl --version | head -n 1
dig -v
```

---

## Étape 5 — Vérifier le réseau

```bash
ip addr
ip route
ping -c 3 1.1.1.1
getent hosts github.com
```

Interprétez les résultats :

- quelle interface possède votre IPv4 ?
- quelle est votre route par défaut ?
- le test vers `1.1.1.1` vérifie-t-il le DNS ? Pourquoi ?
- que valide `getent hosts github.com` ?

> [!NOTE]
> Selon le réseau de l'école, ICMP ou certains accès Internet peuvent être filtrés. Dans ce cas, basez-vous sur `ip route`, `getent` et les consignes du formateur.

---

## Étape 6 — Vérifier les disques

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
```

Vous devez retrouver :

- le disque système contenant `/` ;
- un second disque d'au moins 5 Go ;
- **aucun filesystem ni point de montage sur ce second disque**.

Ne modifiez rien sur ce disque.

---

## Validation automatique

Depuis la racine du dépôt :

```bash
sudo ./scripts/checks/check-tp00.sh
```

Un check en `WARN` n'est pas forcément bloquant : lisez le message et demandez-vous pourquoi le test n'a pas pu être confirmé.

---

## Livrable

Créez `livrables/tp00.txt` :

```text
Hostname        :
OS              :
Kernel          :
Shell           :
IPv4            :
Gateway         :
Interface       :
Disque système  :
Disque data     :
```

---

## 🟠 Challenge — Kernel / distribution / shell

Expliquez en **5 lignes maximum** la différence entre :

- le kernel Linux ;
- une distribution Linux ;
- un shell.

Donnez un exemple pour chaque élément.

## 🔴 Expert — Le paquet vient d'où ?

Choisissez un paquet installé, par exemple `curl`, puis trouvez :

- sa version installée ;
- le dépôt/origine proposé par APT ;
- les fichiers installés par ce paquet.

Aucune commande n'est fournie.
