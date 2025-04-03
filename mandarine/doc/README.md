[TOC]

# Documentation

## Configuration de la FAI
   
Afin de mettre en place la FAI, on va configurer le [routeur1](./configuration/FAI/fai-r1.conf) et le [switch1](./configuration/FAI/fai-s1.conf)

## Configuration des régions

Afin de mettre en place les différentes régions :

[Archi](./archi.md)

## Notre réseau privé

### Matériel 

Nous utilisons le [routeur2](./configuration/Mandarine/mandarine-r2.conf) et le [switch2](./configuration/Mandarine/mandarine-s2.conf).

### Les deux sous-réseaux

Notre réseau privé est constitué de deux sous-réseaux :

| Nom Réseau | Adresse Réseau/24 | Machine dans le réseau | Port dans le switch |
|-|:-:|:-:|:-:|
| info | 192.168.57.0 | Douglas02 | S2 - F0/2 |
| admin | 192.168.58.0 | Douglas04 | S2 - F0/3 |

### Adressage

| Machine | IP |
|:-:|:-:|
| Routeur | .1 |
| Douglas | .2 |

### Dhcp

Nous travaillons sur le service DHCP. Nous avons créé des fichiers de configuration et un VagrantFile :

- [dhcpd.conf](./configuration/Douglas02/dhcp/dhcpd.conf)
- [isc-dhcp-server](./configuration/Douglas02/dhcp/isc-dhcp-server)
- [Vagrantfile](./configuration/Douglas02/dhcp/Vagrantfile)



## Configuration IP des machines physiques

On voit comment configurer l'adresse IP des machines physiques.

- [Douglas01](./configuration/Douglas01/douglas01-ip.conf)
- [Douglas02](./configuration/Douglas02/douglas02-ip.conf)
- [Douglas04](./configuration/Douglas04/douglas04-ip.conf)
