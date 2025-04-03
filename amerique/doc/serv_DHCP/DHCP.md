---
title: Mise en place du service DHCP
---

## Objectif

L'objectif principal de cette configuration est de mettre en place un serveur DHCP capable de fournir des adresses IP dynamiques aux machines de nos différents réseaux. Cela permet de centraliser et d'automatiser la gestion des adresses IP, facilitant ainsi la configuration réseau des équipements sans intervention manuelle sur chaque machine. En attribuant automatiquement une adresse IP, un routeur, et d'autres paramètres réseau essentiel à chaque client, le service DHCP simplifie le déploiement et l'administration des réseaux.

Dans notre infrastructure, le serveur DHCP est destiné à :
- Assurer une attribution automatique et sans conflit des adresses IP au sein de chaque réseau.
- Permettre une gestion dynamique et évolutive du parc machine.
- Fournir des configurations réseaux spécifiques à chaque sous-réseau, tout en centralisant ces configurations dans un seul serveur DHCP.

La mise en œuvre de ce service via Vagrant permet de reproduire et de tester facilement cette infrastructure de manière automatisée et portable.

## Pourquoi isc-dhcp-server ?

La solution que nous allons utiliser est isc dhcp. Elle permet de gérer l'attribution d'adresses IP dans des réseaux complexes, et offre de nombreuses options de configuration. Elle peut être intégrée à d'autres services comme DNS ou LDAP. C’est une solution gratuite, sécurisée et adaptée aux grandes infrastructures. C'est une solution fiable, conforme aux standards DHCP de l'IETF (Internet Engineering Task Force), garantissant une interopérabilité avec de nombreux systèmes et équipements.


### Installation du service et configuration manuelle

``````bash 
apt-get install -y isc-dhcp-server
``````

```conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet <réseau informatique> netmask <son masque>
{
    range <min> <max>;
    option routers <passerelle>;
}

subnet <réseau administratif> netmask <son masque>
{
    range <min> <max>;
    option routers <passerelle>;
}

subnet <réseau production> netmask <son masque>
{
    range <min> <max>;
    option routers <passerelle>;
}
```

Ensuite, nous devons ajouter l'interface qui sera écoutée dans le fichier `etc/default/isc-dhcp-server` :

`````bash
INTERFACESv4="<nom de l'interface à écouter>"
`````

### Test 

Une fois le Vagrantfile complet et opérationnel, nous pouvons effectuer des **tests de requête d'adresses IP** pour les clients avec la commande `dhclient` **ou** simplement en précisant dans notre Vagrantfile le `type: "dhcp` dans la variable de configuration `network`.

sudo dhclient -r <interface> pour libéré une ip dhcp
sudo dhclient -v <interface> pour demander une ip par dhcp

Notre serveur DHCP étant **hebergé sur le réseau informatique (192.168.0.0/24)**, il ne délivre des adresses **uniquement** aux clients de ce **même réseau**.  

### Requêtage d'adresses pour l'ensemble des autres réseaux privés

Afin de palier à ce problème, il est nécessaire de **configurer le routeur** pour lui **indiquer l'existance de notre serveur DHCP** cela se fait grâce à la déclaration :

```mincom
ip-helper-address <ip du serveur dhcp>
```
cela servira de relay dhcp

Cette action est à réaliser dans **toutes les sous-interfaces de nos VLANS**.

Pour que lorsque un client fait une demande dhcp par broadcast, le routeur sache à qui envoyé cette demande dhcp.



## Difficultés rencontrés & Troubleshoot

- ### Problème de collision

Lorsque nous avons brige notre interface de la carte réseau de notre machine virtuelle Vagrant sur l'interface du pc physique de notre machine physique Douglas, nous avons fait face à un problème de collision de réseau.

```
The specified host network collides with a non-hostonly network!
This will cause your specified IP to be inaccessible. Please change
the IP or name of your host only network so that it no longer matches that of
a bridged or non-hostonly network.

Bridged Network Address: '192.168.65.0'
Host-only Network 'enp3s0': '192.168.65.0'
```

Nous avons pu résoudre ce problème en **modifiant** dans la variable de configuration `network` le `private_network` par `public_network`.


- ### Adressage aléatoire

Problème d'attribution d'ip sur les autres réseaux, elle a tendance à être aléatoire :

Nous avons pu observer que lorsqu'on up le serveur dhcp et qu'on requête une ip sur une machine physique d'un autre réseau (douglas06 en l'occurrence) ça ne marche pas ou c'est assez aléatoirement (bloqué à l'étape dhcdiscover). Nous avons effectué le test plusieurs fois, sans succès.


#### Fixation problème DHCP avec les adresses MAC


J'ai repensé au fait que lorsque je démarrais avec vagrant up le dhcp fonctionnait toujours la première fois, mais, ensuite c'est là que les problèmes commençaient après que je fasse des vagrant destroy et puis up, les client ne pouvaient plus recevoir d'ip par dhcp, j'ai pas conséquent émis l'hypothèse que lors des nouveau vagrant up l'adresse mac changé et qu'à cause de cela le routeur n'arrivait pas à mettre à jour sa table ARP à cause de vagrant. 

Je suis allé voir Monsieur Hauspie et je lui ai dit que je comptais mettre des mac fixe pour le serveur dhcp ainsi que les clients, il m'a répondu que c'était une bonne initiative et que ça ne ferait pas de mal à l'infra. Il m'a également dit de supprimer les routes crééer par vagrant et de faire un port-miroring sur le switch avec un pc. Lorsque j'ai changé les mac en mettant des fixe, je n'ai plus eu de problème et j'ai remarqué que lorsque dans le routeur, je ne mettais pas des mac fixe, avec la commande show ARP, ce dernier avait des difficulté à mettre à jour sa table ARP.

 Et donc lorsque je mettais des mac fixe je n'avais plus du tout se problème. Nous pouvons donc garder l'ip helper-addresse comme relay dhcp, même si j'ai toujours les serveurs dhcp relay prêts. 

## Retour au sommaire

- [Retourner au sommaire](../../README.md#documentations---liens-rapide)
