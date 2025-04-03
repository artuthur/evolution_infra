#!/bin/bash

# Fonction pour afficher l'aide
function afficher_aide() {
cat << EOF
usage: ./dns-mand-sec.sh [OPTIONS]

Ce script déploie la configuration DNS pour le domaine "mandarine.iut" en tant que serveur DNS secondaire (de secours). 
Il configure les zones DNS nécessaires pour la gestion du réseau et établit la redondance entre les serveurs DNS primaire et secondaire. 
Ce script est utilisé pour la configuration des serveurs DNS esclaves dans le cadre d'un réseau distribué, garantissant une haute disponibilité 
et une résolution DNS continue en cas de défaillance du serveur primaire.

OPTIONS :
    -h, --help   Affiche ce message d'aide

Ce script effectue les tâches suivantes :
    - Mise à jour du système et installation de `bind9` (serveur DNS).
    - Configuration des routes vers les réseaux privé et public.
    - Modification du fichier `/etc/hosts` pour inclure les hôtes de la partie publique et privée.
    - Configuration des zones DNS pour le domaine "mandarine.iut" et le sous-domaine inverse "10.192.0.0/24" en tant que serveur secondaire.
    - Configuration de la zone maîtresse inverse pour le sous-domaine `mandarine.iut` et les enregistrements PTR associés.
    - Mise en place de la résolution DNS inverse pour l'adressage IP.
    - Ajout d'enregistrements A et PTR pour les services web, mail et DNS.
    - Configuration des options globales dans `named.conf.options` pour autoriser la mise en cache et la résolution des noms externes.
    - Démarrage du service DNS (`named`) pour activer la configuration.

Le domaine configuré est "mandarine.iut", avec des serveurs DNS maîtres et secondaires répartis géographiquement pour garantir une haute disponibilité 
des services de résolution DNS et la redondance du réseau.

EOF
}


# Gestion des options
if [[ "$#" -eq 1 && "$1" == "-h" ]] || [[ "$#" -eq 1 && "$1" == "--help" ]]; then
    afficher_aide
    exit 0
elif [[ "$#" -gt 0 ]]; then
    echo "Erreur: Argument non reconnu : $1\n"
    echo "Pour plus d'aide veuillez taper la commande suivante : ./dns-mand-sec.sh -h ou ./dns-mand-sec.sh --help"
    exit 1
fi

apt-get update -y

# Installation de bind9
apt install bind9 bind9utils bind9-doc -y

# Mise en place d'une route vers le réseau 10.0.0.0/8
ip r add 10.0.0.0/8 via 10.192.0.254 dev eth1
ip r add 192.168.56.0/22 via 10.192.0.254 dev eth1

# Configuration du serveur DNS dans resolv.conf
cat << TUTU > /etc/resolv.conf
nameserver 10.192.0.2
nameserver 10.192.0.6
TUTU

cat << EOF >> /etc/hosts
# Partie publique
10.192.0.2 dns-mandarine.iut
10.192.0.3 mail.mandarine.iut
10.192.0.3 web.mandarine.iut
10.192.0.5 dns-iut
10.192.0.6 dns-mandarine.iut-sec
10.192.0.50 dns-iut-sec

#Partie privé
192.168.57.3 dhcp
192.168.57.4 ldap
192.168.57.5 nfs
EOF

# Début de la configuration du DNS mandarine
# Création des zones dans le fichier named.conf.local 
cat << TOTO > /etc/bind/named.conf.local
# Configuration en tant qu'esclave pour le domaine iut
zone "iut" {
    type slave;
    file "/var/cache/bind/db.iut";
    masters { 10.192.0.5; };  # Serveur maître .iut
};

zone "10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.10-ptr";
    masters { 10.192.0.5; };
};

zone "mandarine.iut" {
    type slave;
    file "/var/cache/bind/db.mandarine.iut";
    masters { 10.192.0.2; };  # Adresse IP de ton DNS principal
};

zone "0.192.10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.2.0.192.10-ptr";
    masters { 10.192.0.2; };  # Adresse IP de ton DNS principal
};
TOTO

# Configuration des options globales dans named.conf.options
cat << DNS > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    
    dnssec-validation auto;

    listen-on-v6 { any; };

    forwarders {
        10.192.0.5;  # Adresse du maître pour la résolution externe
    };

    recursion yes;

    allow-query { 192.168.57.0/24; 130.130.0.0/16; 192.168.58.0/24; 10.0.0.0/8; };
    allow-query-cache { 192.168.57.0/24; 130.130.0.0/16; 192.168.58.0/24; 10.0.0.0/8; };
};
DNS

systemctl restart named.service
