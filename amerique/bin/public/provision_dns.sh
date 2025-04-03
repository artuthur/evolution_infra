#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: provision_dns [OPTIONS]

Résumé :
    Ce script configure automatiquement un serveur DNS maître sur une machine Vagrant à l'aide de Bind9.

Description :
    - Installe le paquet `bind9` si nécessaire.
    - Applique les fichiers de configuration DNS avec nos fichiers personnalisés fournis :
      - named.conf.local
      - db.amerique.iut
      - db.10.64
      - named.conf.options
    - Redémarre le service `bind9` pour appliquer les nouvelles configurations.
    - Définit des serveurs de noms spécifiques dans le fichier `/etc/resolv.conf`.
    - Ajoute une route pour le réseau `10.0.0.0/8` sur l'interface `eth1`.

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

apt-get -qy update && apt-get install -qy bind9
apt-get -qy clean
cp /home/vagrant/dns/named.conf.local /etc/bind/named.conf.local
cp /home/vagrant/dns/db.amerique.iut /etc/bind/db.amerique.iut
cp /home/vagrant/dns/db.10.64 /etc/bind/db.10.64
cp /home/vagrant/dns/named.conf.options /etc/bind/named.conf.options
systemctl restart bind9

echo -e "nameserver 10.64.0.2\nnameserver 10.64.0.5" |  tee /etc/resolv.conf > /dev/null

ip route add 10.0.0.0/8 dev eth1
