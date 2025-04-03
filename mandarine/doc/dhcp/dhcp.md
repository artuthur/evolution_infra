# Service DHCP avec Vagrant et ISC-DHCP-Server  

## Introduction  

Cette procédure explique comment mettre en place un service DHCP à l'aide de **Vagrant** et du paquet **isc-dhcp-server**.  

Le serveur DHCP attribue des adresses IP dynamiques aux machines sur le réseau, selon leur sous-réseau. Grâce à **Vagrant**, le serveur DHCP est configuré rapidement avec les paramètres déjà définis.  

## Configuration réseau et machine virtuelle  

### Machine virtuelle  

- **Nom de la machine** : `srv-dhcp`  
- **Adresse IP** : `192.168.57.5` (réseau privé)  
- **Passerelle** : La machine hôte `Douglas02`, qui agit comme un bridge entre l’ordinateur physique et la machine virtuelle.  

### Fichier Vagrant  
Le fichier `Vagrantfile` contient toutes les instructions nécessaires à la création et configuration de la machine virtuelle. Ce fichier se trouve ici :  
[dhcp](../../bin/srv-dhcp/Vagrantfile).  

## Configuration réseau  

### Ajout des routes  

Pour assurer la communication entre le serveur DHCP, les autres machines, et l'accès à Internet, ajoutez les routes suivantes :  

```bash
ip r add 10.0.0.0/8 via 192.168.57.1 dev eth1  
ip r add 192.168.56.0/22 via 192.168.57.1 dev eth1  
```  

- **10.0.0.0/8** : Plage IP couvrant le réseau public configuré.  
- **192.168.56.0/22** : Permet la communication avec les sous-réseaux privés.  
- **192.168.57.1** : Adresse IP de la passerelle utilisée pour la communication.  

### Configuration DNS  

Le fichier `/etc/resolv.conf` est mis à jour pour pointer vers les serveurs DNS internes :  

```bash
cat << EOF > /etc/resolv.conf  
nameserver 10.192.0.2  
nameserver 10.192.0.6  
EOF  
```  

## Installation et configuration d'ISC-DHCP-Server  

### Installation  

Installez le paquet **isc-dhcp-server** :  

```bash
apt-get update && apt-get -y install isc-dhcp-server  
```  

## Configuration du serveur DHCP  

### Fichier `dhcpd.conf`  

Le fichier `/etc/dhcp/dhcpd.conf` définit les plages d'adresses IP et les options du DHCP :  

```bash
cat << EOF > /etc/dhcp/dhcpd.conf  
# Configuration DHCP  

subnet 192.168.57.0 netmask 255.255.255.0 {  
    range 192.168.57.20 192.168.57.70;  
    option routers 192.168.57.1;  
    option domain-name-servers 10.192.0.2;
    option domain-name-servers 10.192.0.6;  
}  

subnet 192.168.58.0 netmask 255.255.255.0 {  
    range 192.168.58.20 192.168.58.70;  
    option routers 192.168.58.1;  
    option domain-name-servers 10.192.0.2;
    option domain-name-servers 10.192.0.6;  
}  
EOF  
```  

- **Range** : Définit la plage d'adresses attribuées par le serveur DHCP.  
- **Option routers** : Spécifie la passerelle par défaut pour chaque sous-réseau.  
- **Option domain-name-servers** : Configure le serveur DNS pour les machines clientes.  

### Fichier `isc-dhcp-server`  

Le fichier `/etc/default/isc-dhcp-server` spécifie les interfaces sur lesquelles le serveur DHCP écoute :  

```bash
cat << SAE > /etc/default/isc-dhcp-server  
# Configuration ISC-DHCP-Server  

# Interface réseau pour écouter les requêtes DHCP  
INTERFACESv4="eth1"  
INTERFACESv6=""  
SAE  
```  

## Activation du service DHCP  

### Démarrage du service  

Activez et démarrez le service **isc-dhcp-server** :  

```bash
systemctl start isc-dhcp-server.service  
```  

### Vérification du statut  

Vérifiez que le service fonctionne correctement :  

```bash
systemctl status isc-dhcp-server.service  
```  

Le service est maintenant opérationnel et attribue des adresses IP aux machines clientes du réseau configuré.   