#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: provision_dns2 [OPTIONS]

Résumé :
    Ce script configure automatiquement un second serveur DNS à l'aide de Bind9 afin de prendre la relève du DNS principale en cas d'indisponibilité.

Description :
    - Installe le paquet `bind9` si nécessaire.
    - Ajoute une route statique pour le réseau `10.0.0.0/8` via l'interface `eth1`.
    - Configure `named.conf.local` pour déclarer les zones DNS en tant qu'esclave, pointant vers le serveur maître.
    - Définit les options DNS dans `named.conf.options`, incluant :
        - Autorisation de requêtes récursives pour tous.
        - Désactivation de la validation DNSSEC.
        - Définition de serveurs de redirection spécifiques.
    - Modifie la configuration systemd pour forcer l'utilisation de l'option `-4` (IPv4 uniquement).
    - Recharge la configuration systemd et redémarre le service `bind9` pour appliquer les nouvelles configurations.
    - Configure `resolv.conf` pour utiliser le serveur DNS local (`127.0.0.1`).

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

apt-get update
apt-get install -qy bind9

ip r a 10.0.0.0/8 dev eth1

cat > /etc/bind/named.conf.local <<EOF
zone "amerique.iut" {
    type slave;
    file "/var/cache/bind/db.amerique.iut";
    masters { 10.64.0.2; }; # Adresse IP du serveur maître
};
zone "0.64.10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.0.10.64";
    masters { 10.64.0.2; }; # Adresse IP du serveur maître
};
EOF


# Configuration des options pour BIND9
cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-query { any; };
    allow-recursion { any; };
    dnssec-validation no;
    forwarders {
        10.192.0.5;
        10.92.0.50;
    };

    listen-on { any; };
    listen-on-v6 { none; };
};
EOF

# Ajout de l'option -4 dans la configuration du service systemd
sed -i 's|ExecStart=/usr/sbin/named -f $OPTIONS|ExecStart=/usr/sbin/named -f $OPTIONS -4|' /lib/systemd/system/named.service

# Rechargement de la configuration systemd pour inclure la modification
systemctl daemon-reload

# Redémarrage du service BIND9
systemctl restart bind9

# Configuration du serveur DNS local dans resolv.conf
echo "nameserver 127.0.0.1" |  tee /etc/resolv.conf


