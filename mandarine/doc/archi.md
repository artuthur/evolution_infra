## Topologie du réseau :

| Region | Reseau en /16 | Passerelle FAI | Ip routeur Région |
|:------:|:-------------:|:--------------:|:-----------------:|
| Afrique | 10.0.0.0 | 10.0.0.254 | 10.0.0.1 |
| Amerique | 10.64.0.0 | 10.64.0.254 | 10.64.0.1 |
| Asie | 10.128.0.0 | 10.128.0.254 | 10.128.0.1 |
| Mandarine | 10.192.0.0 | 10.192.0.254 | 10.192.0.1 |

## Configurer le routeur r1 et le switch s2 de chaque région

Afin de permettre une communication via le réseau public, nous allons appliquer ce fichier des configuration dans chacun des routeurs 1 de chaque région.
D'abord, la [configuration du routeur R1](./configuration/region/region-r1.conf). Elle nous permet de :

* Changer le nom du matériel
* Configurer l'interface FastEthernet4.10
    * Encapsuler la bonne VLan
    * Attribuer la bonne adresse IP
* Configurer la route par défaut (0.0.0.0 0.0.0.0) via la passerelle attribuée  au routeur FAI


Pour se faire, il faudra simplement remplacer **NOM**, **VLAN**, **ADRESSE** et **ROUTEUR** par les valeurs correspondantes à chaque région :

| région | NOM | VLAN | ADRESSE | ROUTEUR |
|:-------|:---:|:----:|:-------:|:-------:|
| afrique | Afrique | 10 | 10.0.0.1 | 10.0.0.254 |
| amérique | Amerique | 20 | 10.64.0.1 | 10.64.0.254 |
| asie | Asie | 30 | 10.128.0.1 | 10.128.0.254 |
| mandarine | Mandarine | 40 | 10.192.0.1 | 10.192.0.254 |



Maintenant, la [configuration du switch S2](./configuration/region/region-s2.conf). Elle nous permet de :

* Changer le nom du matériel
* Créer une Vlan (numéro, nom)
* Configurer l'interface FastEthernet0/1
* Configurer l'interface GigabitEthernet0/1


Pour se faire, il faudra simplement remplacer, **NUMERO** et **NOM** par les valeurs correspondantes à chaque région :

| région | NUMERO | NOM |
|:-------|:----:|:-------:|
| afrique | 10 | VLAN0010 |
| amérique | 20 | VLAN0020 |
| asie | 30 | VLAN0030 |
| mandarine | 40 | VLAN0040 |
