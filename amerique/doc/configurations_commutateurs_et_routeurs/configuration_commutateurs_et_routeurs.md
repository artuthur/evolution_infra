---
title: Configuration commutateurs et routeurs.
author: 
- Younes Bensyed
---

# Topologie physique

![topologie physique](../img/topologie_reseau/topologie_réseau.jpg)

## Réseau privée

Pour cette première version de notre infrastructure, nous avons décidé de nous **concentrer** sur la **partie privée** de celle-ci.  
Elle est constituée de **3 réseaux privés** différents représentant **un service chacun** :
- Informatique
  - Adresse de réseau : 192.168.65.0/24 - VLAN 10
  - Passerelle : 192.168.65.254
    - Machine : Douglas05
- Administration
  - Adresse de réseau : 192.168.66.0/24 - VLAN 11
  - Passerelle : 192.168.66.254
    - Machine : Douglas06
- Production
  - Adresse de réseau : 192.168.67.0/24 - VLAN 12
  - Passerelle : 192.168.67.254
    - Machine : Douglas07

### Raisonnement

Chacun de nos réseaux se trouve sur un VLAN différent (virtual local area network), cela permet une isolation de chaque réseau et augmente par conséquent la sécurité de chacun, un pirate informatique ne doit pas avoir directement accès à l'entièreté du réseau, il est nécessaire de lui rendre la tâche la plus compliqué possible, par exemple un pirate qui prends le contrôle d'un poste client du service administratif ne doit pas directement accès à tout les services tel que le serveur nfs, proxy ect...
Les vlan permettent également d'améliorer la gestion de son réseau en spécificiant par exemple les règles de filtrage du pare-feu selon les réseaux spécifiques pour autoriser ou non l'accès à une ressource par exemple.

Nos postes clients sont raccordés à un switch. Un switch est un équipement réseau de couche 2 (liaison) sur le modèle OSI, qui permet à plusieurs postes clients ou serveur de pouvoir communiquer entre eux grâce aux trames, un switch ne gère pas les adresses ip, car cela est la couche numéro 3 du modèle OSI. 


# Configuration du switch 1

Pour passer en mode privilégié

```sh
enable
```
pour aller plus, vite on peut juste écrire le début : en

Pour passer en mode de configuration
```sh
configure terminal 
```
Egalement pour aller plus plus on peut juste écrire: conf t

Nous pouvons lui définir un hostname:
```sh
hostname S1amerique
```

Au sein du switch, nous avons créé des vlan différents, dans le mode de configuration.
```shell
vlan <numéro du vlan>
```

on lui choisi un nom
```shell
name informatique
```

```sh
exit
```

Nous allons dans l'interface qui est reliée à douglas05 par exemple si nous voulons qu'il passe par ce vlan

```
int fa0/1
```

Nous choisissons, le mode du switchport ici, se sera le mode access pour permettre l'accessibilité au port par un seul vlan
```shell
switchport mode access
```
Nous allons dans l'interface qui est reliée à douglas05

On choisi ensuite le vlan
```shell
switchport access vlan 10
```

Nous répétons ces mêmes étapes pour tout nos vlan à créer sur le switch, donc pour administratif ainsi que production avec les vlan 11 et 12, selon les interfaces de liaison avec les douglas.

Le switch doit pouvoir laisser passer tout le trafic vlan par une interface, par exemple la GigabitEthernet0/1

```sh
int gig0/1
```
Le mode trunk met en oeuvre une réécriture des trames pour pouvoir faire passer plusieurs VLAN sur le même lien physique. Cette façon de faire est définie par l'IEEE dans la norme 802.1Q. Le commutateur recevant la trame doit la re-décapsuler pour mettre les paquets dans le bon VLAN.

```sh
switchport mode trunk
```

Et nous allons brancher un câble RJ45 du switch1 en gig0/1 au routeur 2 en fa4 qui sera son interface de configuration pour router on a stick.

# Configuration Routeur 2 pour le réseau privé

## Routeur on a stick

Le Router on a Stick est une configuration qui utilise une seule interface physique d'un routeur pour acheminer le trafic entre plusieurs VLAN distincts. Plutôt que de dédier une interface physique à chaque VLAN, le routeur utilise une connexion Trunk vers un commutateur capable de marquer le trafic avec des étiquettes VLAN. Cela permet au routeur de traiter le trafic de plusieurs VLAN sur une seule interface. Cela est différent du routage par interface physique qui nécessite 1 interface par vlan, on peut ainsi économiser les interfaces physiques.

Pour se rendre la dans sous interface virtuel
```sh
int fa4.10
```
Pour configurer notre première sous interface

Nous activons le mode 802.1Q pour le VLAN 10, permettant de taguer les trames VLAN.
```sh
 encapsulation dot1Q 10
```
On lui assigne une ip qui nous servira de passerelle avec son masque
```sh
ip address 192.168.65.254 255.255.255.0
```
Nous lui indiquons la redirection des requêtes DHCP (ip du serveur dhcp)

```sh
ip helper-address 192.168.65.10
```
Nous configurons cette interface comme source interne pour la traduction d'adresses réseau (NAT)
```sh
ip nat inside
```

## vlan d'interconnexion au pare-feu du routeur 2

Notre routeur 2 est relié à notre pare-feu, qui a comme ip sur son interface "in": 192.168.68.2, nous devons donc permettre u trafic de circuler jusqu'à là, et pour cela, nous allons créer un vlan d'interconnexion.

```sh
int vlan 5
```
```sh
ip address 192.168.68.1 255.255.255.248
ip nat inside
```

L'interface du routeur qui sera relié au pare-feu sur son interface "in" sera l'interface FastEthernet3 du routeur 2
 
```sh
int fa3
```

```sh
switchport access vlan 5
```

## les routes du routeur 2

On défini les chemins vers les réseaux spécifiques:

Le trafic destiné au réseau 10.0.0.0/8 (réseau public) via le next-hop 192.168.68.2(interface in du pare-feu).
```sh
ip route 10.0.0.0 255.0.0.0 192.168.68.2
```
Le trafic destiné au réseau 192.168.69.0/29(vlan d'interconnexion coté public) via le next-hop 192.168.68.2.
```sh
ip route 192.168.69.0 255.255.255.248 192.168.68.2
```
# Attention au pare-feu

Ce dernier une fois branché doit être configuré, car il bloque l'intégralité du trafic entre le réseau privé et public.

# Configuration Routeur 1 pour le réseau public

Pour la configuration de la partie publique de notre réseau, nous nous sommes aligné à la solution trouvé du groupe mandarine (FAI) pour se conformer à leur problème d'adressage.

## vlan d'interconnexion du routeur 1

Nous créons également le vlan d'interconnexion sur notre routeur 1, le pare-feu se trouvant entre le routeur 2 et le routeur 1.

```sh
int vlan5
```
```sh
ip address 192.168.69.2 255.255.255.248
ip nat inside
```

```sh
int fa3
```
```sh
switchport access vlan 5
```

## Routeur on  stick routeur 2

Routage on a stick afin de communiquer avec les autres groupes de la sae, fait avec le groupe fai (mandarine)

sous interface décidé par fai
```sh
int fa4.20
```
vlan et ip public la 10.64.0.1/16 distribué par fai pour communiquer avec les autres groupes de la sae

```sh
encapsulation dot1Q 20
ip address 10.64.0.1 255.255.0.0
```
le "ip nat outside" est utilisé pour désigner l'interface connectée au réseau externe (Internet ou WAN) afin que la NAT puisse traduire les adresses IP internes en adresses externes.
```sh
ip nat outside
```

## NAT PAT
La NAT traduit les IP internes en une IP publique, qui sera 10.64.0.1/16 pour nous.
Cela permet aux réseaux internes de communiquer via FastEthernet4.20 tout en partageant une unique ip publique.


```sh
ip nat inside source list 1 interface FastEthernet4.20 overload
```

On met des listes de contrôle d'accès, afin de définir les ip autorisé pour la traduction.

```sh
access-list 1 permit 192.168.65.0 0.0.0.255
access-list 1 permit 192.168.66.0 0.0.0.255
access-list 1 permit 192.168.67.0 0.0.0.255
```


## Les routes du routeur 2

Tout trafic vers des destinations inconnues (autres groupes de la sae) sera envoyé au next-hop 10.64.0.254.
```sh
ip route 0.0.0.0 0.0.0.0 10.64.0.254
```
Les Routes pour le trafic destiné à nos réseau privé via le next-hop 192.168.69.1.
```sh
ip route 192.168.65.0 255.255.255.0 192.168.69.1
ip route 192.168.66.0 255.255.255.0 192.168.69.1
ip route 192.168.67.0 255.255.255.0 192.168.69.1
```
Route pour le trafic destiné au réseau 192.168.68.0/29 (vlan d'interconnexion coté privé) via 192.168.69.1.
```sh
ip route 192.168.68.0 255.255.255.248 192.168.69.1
```

## La translation de port

Pour avoir accès à la base ldap qui se trouve sur le réseau privé depuis le serveur mail qui se trouve sur le réseau public, nous devons configurer une NAT statique pour rediriger le port TCP 389 de l'adresse 192.168.65.3 vers FastEthernet4.20.

```sh
ip nat inside source static tcp 192.168.65.3 389 interface FastEthernet4.20 389
```

Autoriser le trafic TCP sur le port 389 vers 10.64.0.1.
```sh
access-list 101 permit tcp any host 10.64.0.1 eq 389
```

# Sauvegarde de nos configurations

On sauvegarde notre configuration actuelle dans la NVRAM
```sh.
copy running-config startup config
```

On sauvegarde notre configuration dans un fichier
```sh
copy startup-config <le nom qu'on veut donner à la sauvegarde>
```
Pour voir nos fichiers.
```sh
dir flash:
```
Pour copier notre fichier et la mettre dans la configuration actuelle.
```sh
copy <le nom de la sauvegarde> running-config
```


### postes douglas ip et routes

La configuration réseaux des machines Douglas :

```shell
sudo ip addr add <reseau> dev <interface> 
sudo ip link set enp3s0 up # Activation de l'interface
sudo ip route add <reseau> via <passerelle> dev <interface> # Route vers le routeur (passerelle de notre réseau)
```

Nous avons développé un script afin pallier cette tâche répétitive ([script_ip.sh](../bin/conf_reseau/conf_reseau_douglas.sh)) 

Les configurations de routage (switch et routeur) se font via le biais de la commande `minicom` (nous avons devéloppé aussi un [script dédié](../bin/conf_resau/conf_S1.py))



## Retour au sommaire

- [Retourner au sommaire](../README.md#documentations---liens-rapide)

