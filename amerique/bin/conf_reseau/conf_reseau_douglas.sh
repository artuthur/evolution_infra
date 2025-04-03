#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: conf_reseau_douglas [OPTIONS]

Ce script configure les adresses IP et les routes spécifiques pour les serveurs douglas05, douglas06, douglas07 (résaeux privés), et douglas08 (réseau publique).

Description :
  - Configure les adresses IP et les routes internes pour les serveurs douglas05, douglas06, douglas07.
  - Configure une adresse IP publique et une route pour le serveur douglas08.

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

configurer_reseau() {
    local id=$1
    local ip_base=$2
    local route_via=$3

    if [[ "$id" == "8" ]]; then
        ip_address="10.64.0.14/16"
        route_network="10.0.0.0/8"
        route_gateway="10.64.0.254"
        route_network2="192.168.0.0/16"
    else
        ip_address="$ip_base.1/24"
        route_network="192.168.0.0/16"
        route_gateway="$route_via"
        route_network2="10.0.0.0/8"
    fi

    ssh cisco@douglas0$id -C "
        # Vérifier si l'adresse IP est déjà configurée
        if ! ip addr show dev enp3s0 | grep -q '$ip_address'; then
            echo \"Ajout de l'adresse IP $ip_address\"
            sudo ip addr add $ip_address dev enp3s0
        else
            echo \"L'adresse IP $ip_address est déjà configurée\"
        fi

        # Vérifier si la route est déjà configurée
        if ! ip route show | grep -q '$route_network via $route_gateway'; then
            echo \"Ajout de la route vers $route_network via $route_gateway\"
            sudo ip route add $route_network via $route_gateway dev enp3s0
            sudo ip route add $route_network2 dev enp3s0
        else
            echo \"La route vers $route_network via $route_gateway est déjà configurée\"
        fi
    "
}

configurer_reseau 5 192.168.65 192.168.65.254
configurer_reseau 6 192.168.66 192.168.66.254
configurer_reseau 7 192.168.67 192.168.67.254
configurer_reseau 8 10.64.0 10.64.0.254
