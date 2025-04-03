---
title: SAÉ 5B.01
subtitle: Évolution d'une infrastructure
date: 2024/2025
---

# Sujet

L’objet de la SAÉ (Situation d'Apprentissage et d'Évaluation) 5B.01
est de permettre de mettre en œuvre la plupart des compétences
acquises lors des quatre premiers semestres de BUT sur une mise en
application proche d’un cas réel.

L’objectif du projet est de mettre en place une infrastructure
d’entreprise pour 4 organisations différentes dont une aura le rôle de
Fournisseur d'Accès à l'Internet (FAI) pour les 3 autres. Chaque
organisation sera gérée par un groupe d'étudiants (une **équipe**).

## Contraintes communes

Pour chaque organisation l'infrastructure doit correspondre aux
contraintes spécifiées ici.

### Réseau

Toutes les organisation doivent avoir un réseau comportant 2 parties
distinctes :

- une partie **publique**, i.e. avec des adresses IP accessibles par
  toutes les autres organisations

- une partie **privée**, i.e. avec des adresses IP privées accessibles
  **uniquement** par les ordinateurs de l'organisation (donc par
  exemple pas par les ordinateurs des autres organisations).

Le réseau **public** doit offrir les services suivants :

- un serveur DNS **autorité** sur le nom attribué à l'organisation
- un serveur email pour le domaine attribué à l'organisation
- un serveur web

La partie privée doit offir au moins 2 réseaux privés :

- un réseau réservé aux machines du service informatique
- un réseau réservé aux machines du service administratif

Les réseaux privés informatique et administratif doivent pouvoir
accéder complètement à l'Internet (i.e. aux réseaux publics des autres
organisations et des machines qui y sont connectées)

Les flux de ces différents réseaux doivent être séparés pour assurer
la qualité de service du réseau. Toutefois, une communication entre
les machines des services doit être possible.

Les réseaux privés sont *sécurisés* par un serveur jouant le
rôle de pare-feu.

### Services

Le réseau privé du service informatique doit héberger a minima :

- un service DHCP pour toutes les machines privées de l'organisation
- un service LDAP définissant les utilisateurs et groupes des
  différentes machines de l'organisation
- un service NFS stockant les données des différentes utilisateurs
  des machines de l'organisation
- une station de travail avec au minium les outils suivants
  installés et configurés de manière cohérente :
    - navigateur web
    - outil de gestion des emails

Le réseau privé du service administratif doit héberger a minima deux
stations de travail avec au minium les outils suivants installés et
configurés de manière cohérente :

- navigateur web
- outil de gestion des emails

Chaque organisation doit gérer a minima autant d'utilisateurs que
d'étudiants dans le groupe.

Tous les utilisateurs doivent être capable de s'échanger des emails, y
compris d'une organisation à une autre.

Toutes les ordinateurs et services de l'organisation doivent être
désignés par un nom différent.

## Contraintes spécifiques

### FAI

L'organisation FAI doit

- offrir un **tranche** d'adresses IP *publiques* à chacune des autres
  organisations et assurer le routage entre chacune de ces
  organisations en fournissant toutes les informations nécessaires à
  celles-ci.

- offrir un serveur DNS récursif permettant de résoudre correctement
  non seulement tous les noms du DNS standard mais également ceux du
  TLD `iut`.

  Le FAI doit être l'autorité du TLD `iut` et déléguer l'autorité et
  la gestion des sous-domaines affectés à chacune des autres
  organisations.

### Autres organisations

Les autres organisations doivent avoir chacune 1 réseau privé
supplémentaire réservé aux machines du service de production.

Le réseau privé de production ne doit pouvoir se connecter à
l'Internet (i.e. aux réseaux publics des autres organisations)
uniquement via le web et à travers un proxy web de l'organisation.

En conséquence le réseau privé du service informatique des autres
organisations doit donc héberger en plus un service proxy web.

Le réseau privé du service production doit héberger a minima deux
stations de travail avec au minium les outils suivants installés et
configurés de manière cohérente :

- navigateur web
- outil de gestion des emails

## Extensions

Si l’ensemble de ces éléments a pu être mis en œuvre avant la fin du
projet, on pourra mettre en place les éléments suivants :

1. Fournir l’ensemble des services en IPv4 **et** en IPv6

2. offrir un accès sécurisé depuis un réseau extérieur (VPN)

3. offrir aux utilisateurs un accès Wifi.

  Le flux correspondant sera séparé des autres flux et permettra
  uniquement le flux HTTP.

# Logistique

## Séances

Les séances ont lieu lors des semaines où les étudiants alternants
sont en entreprise.

Pour l'année 2023-2024 cela correspond à 

- semaine 40 du 30/09 au 04/10
- semaine 42 du 14/10 au 18/10
- semaine 46 du 12/11 au 15/11
- semaine 48 du 25/11 au 29/12
- semaine 02 du 06/01 au 10/01
- semaine 04 du 20/01 au 24/01

Pendant vos séances de TP, une salle de TP classique ainsi que la
salle de TP réseau sont à votre disposition.

## Évaluation

Vous devrez produire un document de synthèse et faire une
démonstration des maquettes. Cette évaluation sera faite lors d'une
séance en janvier dont la date sera fixée tardivement dans le
semestre.

## Salle de TP réseau (4A37)

Chaque groupe a la responsabilité d'un poste de travail.

Sur chaque poste de travail il y 4 machines nommées `douglasNN` avec
`NN` 4 valeurs entières ansi qu'une baie réseau.

L'utilisateur de chacune des machines est `cisco` avec le mot de passe
spécifié en cours. Cet utilisateur a le droit de modifier la
configuration réseau de la machine à travers `sudo`.

Chaque machine a 2 cartes réseaux physiques :

- une carte réseau connectée sur le réseau privé des salles de TP :
  `172.18.48.0/22`. Cette carte est configurée au démarrage de la
  machine par le DHCP du département. **Sa configuration ne doit pas
  être modifiée**.
- une carte supplémentaire connectée directement à la baie réseeau
  (via le patch du bas de la baie).
  
Au moins une des machines du poste est équipée d'un cable
série-ethernet (cable plat bleu) permettant de se connecter
directement au port de contrôle des équipements réseaux de la baie via
l'outil `minicom` installé en standard sur les machines du poste de
travail.

Chaque baie réseau est équipée du haut vers le bas par :

- un commutateur (`R0`)
- deux routeurs (`R1` et `R2`)
- un patch de brassage vers les éléments actifs
- 4 commutateurs (`S1`, `S2`, `S3`, `S4`)
- un patch de brassage vers les machines de travail

## Suivi du projet

Le projet est géré en respectant quelques [règles](projet-regles.md)
et [conventions](projet-conventions.md) et en utilisant des
[outils](outils/README.md).

Le respect de celles-ci est **obligatoire** et sera pris en compte
pour l'évaluation finale.

La gestion et le suivi du projet se font sur le serveur GitLab de
l’université (https://gitlab.univ-lille.fr). Le projet dont les
étudiants sont membres doit servir à la fois à rédiger et sauvegarder
configurations et documentations mais aussi à gérer vos tâches
(tickets et jalons).

## Organisation du travail

En interne les étudiants organisent comme ils l'entendent leur
travail. Cette organisation doit dans tous les cas être **décrite et
documentée**.

Cependant un seul projet (au sens GitLab) est utilisé pour l'ensemble
des organisations. Des règles de travail, **collaboration** entre
équipes et de **partage** du projet et ses outils doivent donc sans
doute être établies. Elles doivent également être décrites et
documentées de manière **commune**.

Dans la mesure où certaines des compétences nécessaires seront
acquises durant le semestre, il faudra adopter une démarche
progressive permettant d’intégrer au fur et à mesure les différents
éléments. Pour cela une discussion avec les enseignants concernés du
planning possible est sans doute envisageable.

Cependant certains services ou technologies ne seront pas forcément
abordés en cours. Il faudra alors les étudier et déterminer comment
les mettre en place.

# Équipes

Les étudiants suivants ne peuvent pas être dans la même équipe :

- halim.benia-latreche.etu
- youssef.megahed.etu
- younes.bensyed.etu
- soufiane.kraba.etu

## [Équipe Mandarine (FAI)](equipe-mandarine/README.md)

- Membres
- DNS : `mandarine.iut`

## [Équipe Afrique](equipe-afrique/README.md) : 

- Membres
- DNS : `afrique.iut`

## [Équipe Amérique](equipe-amerique/README.md) : 

- Membres
- DNS : `amerique.iut`

## [Équipe Asie](equipe-asie/README.md) :

- Membres
- DNS : `asie.iut`
 

