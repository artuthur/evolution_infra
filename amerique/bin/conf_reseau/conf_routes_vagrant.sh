#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: conf_routes_vagrant [OPTIONS]

Ce script configure l'utilisation de notre serveur DNS ainsi que les routes spécifiques pour accéder aux différents réseaux privés ainsi qu'au réseau public.

Description :
  - Configure les routes pour l'accès au réseau public et aux réseaux privés grâce à ip route.
  - Configure l'utilisation du serveur DNS dans le fichier resolv.conf.

Options:
    -h, --help        Affiche ce message d'aide.

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

sudo ip r a 192.168.0.0/16 dev eth1 2> /dev/null
sudo ip r a 10.0.0.0/8 dev eth1 2> /dev/null

echo "nameserver 10.64.0.2" | sudo tee -a /etc/resolv.conf
