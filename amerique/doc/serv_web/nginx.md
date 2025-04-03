---
title: Mise en place du serveur web
---

# Mise en place du serveur web

Nous avons choisi d'utiliser le service `nginx` par rapport à `apache` en tant que serveur web.

## Objectif

L'objectif est de déployer un serveur web pour héberger une simple page d'accueil présentant notre organisation. Cette page permettra aux utilisateurs d'accéder à une simple page d'accueuil de notre organisation. La solution doit être légère, rapide à mettre en place, et capable de gérer un flux modéré de visiteurs, tout en étant compatible avec des outils d'automatisation comme Vagrant pour faciliter les déploiements futurs.

## Pourquoi Nginx ?

Nous avons choisi Nginx comme serveur web pour plusieurs raisons qui le rendent plus adapté à notre contexte qu'Apache ou d'autres alternatives :

- **Performance et efficacité** : Nginx est particulièrement efficace pour servir des contenus statiques, comme une page d'accueil HTML. Grâce à son architecture asynchrone, il peut gérer un grand nombre de connexions simultanées avec une faible utilisation des ressources, ce qui est un avantage même pour des projets de petite envergure.
  
- **Simplicité de configuration** : Comparé à Apache, la configuration de base de Nginx est légère et bien adaptée à des sites statiques. Sa syntaxe de configuration est également plus concise, ce qui facilite la maintenance.
  
- **Fiabilité et stabilité** : Pour notre page d'accueil, nous privilégions une solution robuste. Nginx est réputé pour sa stabilité même sous forte charge, offrant ainsi une solution de qualité professionnelle pour un serveur web à faible trafic.

- **Compatibilité avec des solutions de conteneurisation et virtualisation** : Nginx est souvent utilisé dans des environnements virtualisés (comme avec Vagrant dans notre cas) ou conteneurisés (Docker). Son intégration avec ces technologies est bien documentée et simplifie la gestion d'environnements multi-services.

Nginx est le choix idéal pour héberger une simple page d'accueil, nous assurant un service rapide, stable et performant.

## Installation et configuration manuelle du service 

Installer le service nginx, il suffit de faire appel au gestionnaire de paquets.

```shell
apt-get update -y
apt-get install nginx -y  
```

Ensuite, nous allons modifier le fichier `index.html` desservi par défaut par notre nginx afin d'afficher un message de bienvenue pour notre organisation Amérique.

```shell
echo "<html><body><h1>Serveur web du groupe Amerique</h1></body></html>" | sudo tee /var/www/html/index.html
```

Enfin, nous pouvons redémarrer notre serveur web pour de prendre en compte les changements :

```shell
sudo systemctl restart nginx.service
```

## Création du Vagrantfile et automatisation

Comme pour le restant de nos services nous avons choisi d'heberger notre serveur web **sous Vagrant**. Le fichier Vagrantfile est le suivant : [fichier vagrant](../../bin/public/Vagrantfile)-Section "web"

Nous avons rajouté un **foward de port** dans le but de pouvoir **visualiser le contenu** de notre serveur web **sur** la machine physique grâce à l'option :

```vagrantfile
web.vm.network "forwarded_port", guest: port_virtuel, host: port_physique
```

Nous pouvons accèder à notre serveur web via l'adresse :

http://10.64.0.2

Néanmoins après avoir configuré notre DNS et l'avoir paramètre pour l'utiliser sur notre machine client nous pouvons y accèder via l'entrée :

http://web.amerique.iut


## Retour au sommaire

- [Retourner au sommaire](../../README.md#documentations---liens-rapide)