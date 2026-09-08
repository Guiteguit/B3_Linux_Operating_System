# TP09 — 💀 FINAL BOSS : Incident P1 sur `srv-linux01`

**Durée cible : 1 h 30 — Niveau : 🔴 — Travail en binôme possible, restitution individuelle**

# Ticket INC-26001

> **09:14 — Incident critique**
> L'application NovaTech n'est plus accessible. Plusieurs modifications ont été réalisées lors d'une intervention de maintenance. Le serveur répond au réseau mais le service applicatif est indisponible ou dégradé. Vous êtes l'équipe d'astreinte.
> **Rétablissez le service, démontrez le retour à la normale et rédigez un mini-RCA.**

---

# Règles

- Vous ne recevez **aucune liste des pannes**.
- Il peut y avoir **plusieurs causes simultanées**.
- Ne réinstallez pas la machine.
- Ne restaurez pas un snapshot sauf autorisation du formateur.
- Ne désactivez pas globalement les mécanismes de sécurité « pour voir si ça marche ».
- Ne modifiez pas dix paramètres à la fois.
- Avant chaque correction significative, notez le **fait observé** et votre **hypothèse**.
- Une hypothèse doit être testée avant modification.

---

# Méthodologie imposée

```text
1. Reproduire le symptôme
2. Observer
3. Délimiter la couche en défaut
4. Collecter les faits
5. Formuler UNE hypothèse
6. Tester l'hypothèse
7. Corriger
8. Valider de bout en bout
9. Documenter
```

Vous devez raisonner par couches :

```text
Client / HTTP
     ↓
Socket / port
     ↓
Service systemd
     ↓
Configuration
     ↓
Filesystem / stockage
     ↓
Permissions / ressources
```

---

# Interdictions

Les réponses suivantes ne constituent pas un diagnostic :

```text
« J'ai rebooté et ça remarche. »
« J'ai chmod 777. »
« J'ai désactivé le firewall. »
« J'ai réinstallé nginx. »
```

Une correction doit être **minimale, justifiée et vérifiable**.

---

# Critères de retour à la normale

À la fin, vous devez pouvoir démontrer :

```text
nginx configuration valide
nginx actif
TCP/80 en écoute
HTTP local fonctionnel
/srv/app monté
mount -a sans erreur
novatech-agent actif et activé au boot
healthcheck exécutable et cohérent
```

Le formateur possède un validateur d'incident indépendant.

---

# Livrable — Mini RCA

Créez :

```text
livrables/tp09-incident.md
```

Modèle :

```markdown
# INC-26001 — Compte rendu

## 1. Symptômes et impact

## 2. Chronologie du diagnostic

| Heure | Fait observé | Hypothèse | Test | Résultat |
|---|---|---|---|---|

## 3. Cause(s) racine(s)

## 4. Correctifs appliqués

## 5. Validation du retour à la normale

## 6. Actions préventives
```

---

# Restitution individuelle

Le formateur peut choisir n'importe quelle ligne de votre RCA et demander :

> « Pourquoi cette commande ? »

ou :

> « Qu'est-ce que son résultat vous a permis d'exclure ? »

La note dépend autant de la **démarche de diagnostic** que du fait d'avoir remis le serveur en état.

## Dernier conseil

> **N'essayez pas de deviner la panne. Réduisez l'espace des causes possibles avec des faits.**
