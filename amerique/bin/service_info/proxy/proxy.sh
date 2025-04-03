#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: proxy [OPTIONS]

Résumé :
    Ce script configure un serveur proxy Squid pour permettre l'accès à Internet depuis le réseau interne spécifié.

Description :
    - Installe les paquets nécessaires pour Squid et curl.
    - Configure Squid pour écouter sur le port 3128.
    - Crée des ACL (Access Control Lists) pour limiter l'accès au réseau 192.168.67.0/24.
    - Refuse toute autre connexion entrante (accès interdit par défaut).
    - Configure les serveurs DNS à utiliser par le serveur Squid.
    - Modifie la configuration de résolveur DNS du système pour utiliser les serveurs DNS 10.64.0.2 et 10.64.0.5, et protège cette configuration contre toute modification.

Options :
    -h, --help        Affiche ce message d'aide.

Note :
    Le script suppose que le réseau interne pour lequel l'accès est autorisé est 192.168.67.0/24.
    Assurez-vous que le serveur Squid est configuré correctement pour votre environnement.
    Cette configuration empêche tout accès extérieur non autorisé et protège les paramètres de DNS.
EOF
}

# Vérifie si l'option -h ou --help est passée en paramètre
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    afficher_aide
    exit 0
elif [[ "$1" != "" && "$1" != "-h" && "$1" != "--help" ]]; then
    echo "Argument invalide : $1  veuillez utiliser -h ou --help pour plus d'informations"
    exit 1
fi

apt-get update -qy
apt-get install curl -qy
apt-get install squid -qy

cat > /etc/squid/squid.conf <<EOF
http_port 3128

# Définition des ACL pour le réseau
acl mynetwork src 192.168.67.0/24
http_access allow mynetwork

# Interdiction de tout autre accès
http_access deny all

# Configuration des DNS
dns_nameservers 10.64.0.2 10.64.0.5
EOF

echo -e "nameserver 10.64.0.2\nnameserver 10.64.0.5" |  tee /etc/resolv.conf > /dev/null
chattr +i /etc/resolv.conf


systemctl restart squid