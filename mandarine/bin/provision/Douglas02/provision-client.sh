#!/bin/bash

# Afficher l'aide si -h ou --help est passé en argument
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Ce script configure un client pour l'authentification via LDAP sur un serveur LDAP."
    echo
    echo "Usage : $0"
    echo
    echo "Le script effectue les actions suivantes :"
    echo "  - Met à jour et installe les paquets nécessaires pour LDAP et NSS."
    echo "  - Configure les paramètres LDAP dans le fichier /etc/nslcd.conf."
    echo "  - Modifie le fichier /etc/nsswitch.conf pour que NSS utilise LDAP."
    echo "  - Configure PAM pour créer un répertoire personnel lors de la connexion de l'utilisateur."
    exit 0
fi

# Paramètres de configuration LDAP
LDAP_SERVER="ldap://192.168.57.4"
BASE_DN="dc=mandarine,dc=iut"
BIND_DN="cn=admin,dc=mandarine,dc=iut"
BIND_PW="admin"

# Mettre à jour le système et installer les paquets nécessaires
sudo apt update && sudo apt upgrade -y

# Installer les paquets nécessaires pour LDAP, NSS et PAM
sudo DEBIAN_FRONTEND=noninteractive apt install -y libnss-ldap libpam-ldap ldap-utils nscd

# Configurer les paramètres par défaut pour ldap-utils
debconf-set-selections <<EOF
libnss-ldap libnss-ldap/ldap-server string ldap://192.168.57.4/
libnss-ldap libnss-ldap/ldap-base string dc=mandarine,dc=iut
libnss-ldap libnss-ldap/nsswitch note
EOF

# Configuration du serveur LDAP dans /etc/nslcd.conf
echo "Configuration du serveur LDAP dans /etc/nslcd.conf..."
echo "uri ldap://192.168.57.4/
base dc=mandarine,dc=iut
binddn cn=admin,dc=mandarine,dc=iut
bindpw admin
ssl off
bind_timelimit 10" | sudo tee /etc/nslcd.conf > /dev/null

# Redémarrer le service nslcd pour appliquer la configuration
sudo systemctl restart nslcd

# Configurer NSS pour utiliser LDAP pour les utilisateurs, groupes et mots de passe
echo "Configuration de NSS pour utiliser LDAP..."
sudo sed -i 's/^passwd:.*/passwd:         files ldap/' /etc/nsswitch.conf
sudo sed -i 's/^group:.*/group:          files ldap/' /etc/nsswitch.conf
sudo sed -i 's/^shadow:.*/shadow:         files ldap/' /etc/nsswitch.conf

# Configurer PAM pour créer des répertoires personnels lors de la connexion
echo "Configuration de PAM pour créer des répertoires personnels..."
echo "session     required      pam_mkhomedir.so skel=/etc/skel umask=0022" | sudo tee -a /etc/pam.d/common-session > /dev/null

# Fin de la configuration
echo "Configuration terminée."