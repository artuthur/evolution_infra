#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: provision_web [OPTIONS]

Résumé :
    Ce script configure automatiquement un serveur web avec Nginx sur une machine Vagrant pour contenir une page d'accueil de notre organisation.

Description :
    - Installe le paquet `nginx` si nécessaire.
    - Crée une page d'accueil par défaut avec le message : "Serveur web du groupe Amerique".
    - Démarre le service `nginx` et l'active pour un démarrage automatique au boot.
    - Configure `resolv.conf` avec des serveurs DNS spécifiques (10.64.0.2 et 10.64.0.5).
    - Ajoute une route statique pour le réseau `10.0.0.0/8` via l'interface `eth1`.

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

## Installation et configuration de notre serveur web
apt-get update -y
apt-get install nginx -y  
echo "<html><body><h1>Serveur web du groupe Amerique</h1></body></html>" |  tee /var/www/html/index.html
systemctl start nginx
systemctl enable nginx

echo -e "nameserver 10.64.0.2\nnameserver 10.64.0.5" |  tee /etc/resolv.conf > /dev/null

ip route add 10.0.0.0/8 dev eth1
