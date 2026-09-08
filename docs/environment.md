# Environnement de lab

## Configuration recommandée

| Ressource | Valeur |
|---|---|
| Distribution | Ubuntu Server 24.04 LTS |
| vCPU | 2 |
| RAM | 2 à 4 Go |
| Disque système | 20 Go minimum |
| Disque data | 5 Go minimum, vierge |
| Réseau | DHCP accepté pour le lab |
| Administration | utilisateur nominatif avec `sudo` |
| SSH | OpenSSH Server |

## Hyperviseur

Le cours ne dépend pas d'un hyperviseur précis. Une VM VMware, VirtualBox, Hyper-V, Proxmox ou équivalent convient tant qu'un **second disque brut** peut être ajouté.

## Avant le TP00

Le formateur doit vérifier :

- que les étudiants peuvent créer ou démarrer une VM ;
- que l'accès Internet permet au minimum les dépôts APT ;
- que le second disque est visible par la VM ;
- qu'aucune politique réseau ne bloque totalement SSH entre poste et VM.

## Snapshots recommandés

Un snapshot peut être utile :

```text
S0 → installation terminée
S1 → fin du Jour 1
S2 → avant le Final Boss
```

Il ne doit cependant pas remplacer le diagnostic pendant les TPs.
