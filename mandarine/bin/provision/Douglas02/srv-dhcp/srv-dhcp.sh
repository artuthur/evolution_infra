# !/bin/bash

# Fonction pour afficher l'aide
function afficher_aide() {
cat << EOF
usage: ./srv-dhcp.sh [OPTIONS]

Ce script configure un serveur DHCP sur le réseau privé, en déployant les 
paramètres nécessaires pour gérer les attributions d'adresses IP. 
Le script configure également les routes, les serveurs DNS, et les fichiers 
de configuration associés.

OPTIONS :
    -h, --help   Affiche ce message d'aide

Ce script effectue les tâches suivantes :
    - Mise à jour du système et installation du serveur DHCP (`isc-dhcp-server`).
    - Configuration des fichiers `/etc/hosts` et `/etc/dhcp/dhcpd.conf` pour 
      définir les plages d'adresses et les serveurs DNS.
    - Ajout de routes spécifiques pour le réseau privé.
    - Démarrage du service DHCP (`isc-dhcp-server`).

EOF
}
# Gestion des options
if [[ "$#" -eq 1 && "$1" == "-h" ]] || [[ "$#" -eq 1 && "$1" == "--help" ]]; then
    afficher_aide
    exit 0
elif [[ "$#" -gt 0 ]]; then
    echo "Erreur: Argument non reconnu : $1\n"
    echo "Pour plus d'aide veuillez taper la commande suivante : ./srv-dhcp.sh -h ou ./srv-dhcp.sh --help"
    exit 1
fi

apt-get update

apt-get -y install isc-dhcp-server

ip r add 10.0.0.0/8 via 192.168.57.1 dev eth1
ip r add 192.168.56.0/22 via 192.168.57.1 dev eth1

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

cat << EOF > /etc/dhcp/dhcpd.conf
# Plage DHCP

subnet 192.168.57.0 netmask 255.255.255.0 {
        range                           192.168.57.20 192.168.57.70;
        option routers                  192.168.57.1;
	    option domain-name-servers	    10.192.0.2;
        option domain-name-servers	    10.192.0.6;
}

subnet 192.168.58.0 netmask 255.255.255.0 {
        range                           192.168.58.20 192.168.58.70;
        option routers                  192.168.58.1;
	    option domain-name-servers	    10.192.0.2;
        option domain-name-servers	    10.192.0.6;
}
EOF

cat << SAE > /etc/default/isc-dhcp-server
# Defaults for isc-dhcp-server (sourced by /etc/init.d/isc-dhcp-server)

# Path to dhcpd's config file (default: /etc/dhcp/dhcpd.conf).
#DHCPDv4_CONF=/etc/dhcp/dhcpd.conf
#DHCPDv6_CONF=/etc/dhcp/dhcpd6.conf

# Path to dhcpd's PID file (default: /var/run/dhcpd.pid).
#DHCPDv4_PID=/var/run/dhcpd.pid
#DHCPDv6_PID=/var/run/dhcpd6.pid

# Additional options to start dhcpd with.
#	Don't use options -cf or -pf here; use DHCPD_CONF/ DHCPD_PID instead
#OPTIONS=""

# On what interfaces should the DHCP server (dhcpd) serve DHCP requests?
#	Separate multiple interfaces with spaces, e.g. "eth0 eth1".
INTERFACESv4="eth1"
INTERFACESv6=""
SAE

systemctl start isc-dhcp-server.service
