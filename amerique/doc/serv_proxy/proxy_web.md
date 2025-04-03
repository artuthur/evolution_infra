---
title: Mise en place du proxy Web du service informatique pour le service production
---

# Pourquoi utiliser un proxy ?

Un proxy est un serveur servant d'intérmédiaire entre un appareil et internet, il permet de surfer indirectement sur le web, donc cela cache l'ip réel des utilisateurs, permet également de faire de la mise en cache ou du contrôle d'accès.

# Pourquoi utiliser Squid comme proxy ?

Nous allons utiliser la solution Squid car c'est une solution très fiable, open-source, qui offre une grande flexibilité de configuration, Squid bénéficie également d'une grande communauté sur internet.

# Mise en place du proxy web pour le service production


Pour configurer nous nous rendons dans le fichier /etc/squid/squid.conf:

```
# Configuration du port sur lequel Squid écoutera
http_port 3128

# Définition des ACL pour le réseau
acl mynetwork src <adresse réseau avec masque en notation CIDR> #adresse réseau du service production
http_access allow mynetwork

# Interdiction de tout autre accès
http_access deny all

# Configuration des DNS
dns_nameservers <ip dns1> <ip dns2>
```

On restart le service
```
systemctl restart squid
```

Pour forcer un client à utiliser le proxy, pour rediriger tout le trafic web via le proxy, il faut se rendre dans /etc/environment:

```
http_proxy="http://<ip du proxy>:3128/"
https_proxy="http://<ip du proxy>:3128/" #on ne met pas en https car c'est simplement le protocol utilisé pour communiquer avec Squid, toute les requêtes passeront par l'ip sur le port 3128 avec http
```

## Retour au sommaire

- [Retourner au sommaire](../../README.md#documentations---liens-rapide)