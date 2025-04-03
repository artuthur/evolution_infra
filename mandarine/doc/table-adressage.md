# Table d'adressage

## Le routeur 1 (Principal)
| Vlan  | Adresse IP de l'interface | Nom de la Vlan | Organisation |
| :---------------: |:---------------:| :-----:| :-----:|
| FastEthernet4.10 | 10.0.0.254 /16 | VLAN0010 | Afirque |
| FastEthernet4.20 | 10.64.0.254 /16 | VLAN0020 | Amérique |
| FastEthernet4.30 | 10.128.0.254 /16 | VLAN0030 | Asie |
| FastEthernet4.40 | 10.192.0.254 /16 | VLAN0040 | Mandarine |


## Commutateur 1
| Nom de la Vlan  | Ports | Adresse IP du port | Organisation |
| :---------------: |:---------------:| :-----:| :-----:|
| VLAN0010 | Fa0/1 | 10.0.0.1 /16 | Afirque |
| VLAN0020 | Fa0/2 | 10.64.0.1 /16 | Amérique |
| VLAN0030 | Fa0/3 | 10.128.0.1 /16 | Asie |
| VLAN0040 | Fa0/4 | 10.192.0.1 /16 | Mandarine |


## Route des organisations
| Organisation  | Route |
| :---------------: |:---------------:| 
| Afirque | 0.0.0.0 0.0.0.0 10.0.0.254 |
| Amérique | 0.0.0.0 0.0.0.0 10.64.0.254 |
| Asie | 0.0.0.0 0.0.0.0 10.128.0.254 |
| Mandarine | 0.0.0.0 0.0.0.0 10.192.0.254 | 

# Utilation d'adresse IP
## Pour le réseau publique 10.192.0.0
| Adresse IP  | Nom de la machine |
| :---------------: |:---------------:| 
| 10.192.0.2 | DNS mandarine |
| 10.192.0.3 | Serveur mail |
| 10.192.0.3 | Serveur web | 
| 10.192.0.5 | DNS iut |
| 10.192.0.6 | DNS mandarine secours |
| 10.192.0.10 | Douglas01 |
| 10.192.0.50 | DNS iut secours |
| 10.192.0.254 | Interface FastEthernet4.40 du routeur FAI |

## Pour le réseau publique 192.168.57.0
| Adresse IP  | Nom de la machine |
| :---------------: |:---------------:| 
| 192.168.57.1 | Interface FastEthernet4.57 du routeur Mandarine |
| 192.168.57.5 | Serveur DHCP |
| 192.168.57.3 | Serveur NFS |
| 192.168.57.4 | Serveur LADP |
| 192.168.57.20 - 70| Plage d'adressage du DHCP |

## Pour le réseau publique 192.168.58.0
| Adresse IP  | Nom de la machine |
| :---------------: |:---------------:| 
| 192.168.58.1 | Interface FastEthernet4.58 du routeur Mandarine |
| 192.168.58.20 - 70| Plage d'adressage du DHCP |

## Pour le réseau 130.130.0.0
| Adresse IP  | Nom de la machine |
| :---------------: |:---------------:| 
| 130.130.1.1 | Interface FastEthernet... du routeur FAI |
| 130.130.1.2 | Port 1 du Firewall |
| 130.130.2.1 | Interface FastEthernet... du routeur FAI |
| 130.130.2.2 | Port 2 du Firewall |