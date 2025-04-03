#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: dhcp_provision [OPTIONS]

Résumé :
    Ce script configure automatiquement un serveur DHCP avec nos sous-réseaux prédéfinis (cf nos différents services).

Description :
    - Installe le paquet `isc-dhcp-server` pour fournir des adresses IP dynamiques.
    - Configure plusieurs sous-réseaux avec des plages d'adresses IP et des routeurs par défaut.
    - Définit l'interface réseau utilisée par le service DHCP (`eth1`).
    - Redémarre et active le service DHCP pour qu'il se lance au démarrage.

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

set -e  # Stop the script if any command fails

apt-get -qy update
apt-get -qy install isc-dhcp-server
apt-get -qy clean

cat << EOF |  tee /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet 192.168.65.0 netmask 255.255.255.0 {
    range 192.168.65.50 192.168.65.150;
    option routers 192.168.65.254;
}

subnet 192.168.66.0 netmask 255.255.255.0 {
    range 192.168.66.50 192.168.66.150;
    option routers 192.168.66.254;
}

subnet 192.168.67.0 netmask 255.255.255.0 {
    range 192.168.67.50 192.168.67.150;
    option routers 192.168.67.254;
}
EOF

sed -i 's/^INTERFACESv4=".*"/INTERFACESv4="eth1"/' /etc/default/isc-dhcp-server

systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server





