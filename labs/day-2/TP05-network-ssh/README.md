# TP05 — Réseau Linux et administration SSH

**Durée cible : 45 min — Niveau : 🟢 → 🟠 → 🔴**

## Contexte

`srv-linux01` doit être administrable à distance. Avant de toucher à SSH, vous devez être capable de **décrire précisément ce que fait le serveur sur le réseau**.

---

# Partie A — Cartographier le réseau 🟢

Retrouvez et notez :

- interface principale ;
- adresse IPv4 ;
- route par défaut ;
- serveurs DNS ;
- ports TCP en écoute ;
- processus associés aux ports ;
- résolution DNS d'un nom public ;
- réponse HTTP locale de nginx.

Commandes à explorer :

```bash
ip -br addr
ip route
resolvectl status
getent hosts example.com
ss -lntp
curl -I http://127.0.0.1
```

Questions :

1. Une machine peut-elle avoir une IP valide mais ne pas savoir joindre Internet ?
2. Un ping vers une IP prouve-t-il que le DNS fonctionne ?
3. Quelle différence entre **adresse**, **route**, **DNS** et **socket** ?

---

# Partie B — SSH 🟢

## Étape 1 — Vérifier le service

Si nécessaire :

```bash
sudo apt install -y openssh-server
```

Puis observez avant toute modification :

```bash
systemctl status ssh
ss -lntp | grep ':22'
```

Depuis une autre machine :

```bash
ssh <user>@<ip_du_serveur>
```

## Étape 2 — Authentification par clé

Sur le **client** :

```bash
ssh-keygen -t ed25519
ssh-copy-id <user>@<ip_du_serveur>
```

Prouvez ensuite qu'une connexion par clé fonctionne :

```bash
ssh -o PreferredAuthentications=publickey \
    -o PasswordAuthentication=no \
    <user>@<ip_du_serveur>
```

Question : où la clé publique autorisée est-elle stockée côté serveur ?

---

# Partie C — Durcissement SSH 🟠

NovaTech impose :

```text
connexion root directe : interdite
accès administrateur  : toujours fonctionnel
configuration invalide : ne doit jamais être rechargée
```

Modifiez la configuration SSH afin d'interdire la connexion directe de `root`.

### Règle de sécurité obligatoire

**Gardez votre session SSH actuelle ouverte.**

Avant toute recharge du service :

1. ouvrez un second terminal ;
2. testez la syntaxe de la configuration ;
3. seulement ensuite rechargez SSH ;
4. ouvrez une nouvelle connexion pour valider.

Indice :

```text
sshd possède un mode de test de configuration.
```

> [!WARNING]
> Ne redémarrez pas aveuglément SSH lorsque vous êtes connecté à distance. Une erreur de configuration peut vous verrouiller dehors.

---

# Partie D — Authentification uniquement par clé 🔴

**Uniquement après avoir démontré que l'authentification par clé fonctionne**, désactivez l'authentification par mot de passe.

Vous devez être capable d'expliquer :

- la différence entre clé privée et clé publique ;
- pourquoi la clé privée ne doit jamais être copiée sur le serveur ;
- la différence entre `restart` et `reload` dans ce contexte.

---

## Validation automatique

Depuis la racine du dépôt :

```bash
sudo ./scripts/checks/check-tp05.sh
```

Le validateur ne peut pas prouver à votre place qu'une connexion distante par clé fonctionne : cette preuve reste à fournir dans le livrable.

---

## Livrable

Créez `livrables/tp05.txt` :

```text
Interface principale :
IPv4               :
Gateway             :
DNS                 :

Ports en écoute :

Test HTTP local :

Connexion SSH par clé validée : OUI/NON
Fichier authorized_keys      :

PermitRootLogin              :
PasswordAuthentication       :
Commande de validation SSH   :
Méthode de reload            :
```

## Question de débrief

Remettez dans l'ordre la méthode de modification d'un service d'accès distant :

```text
modifier / tester / garder une session ouverte / reload / ouvrir une nouvelle session
```
