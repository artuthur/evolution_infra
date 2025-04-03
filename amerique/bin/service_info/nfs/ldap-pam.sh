#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: ldap-pam [OPTIONS]

Résumé :
    Ce script configure un client pour l'authentification LDAP avec PAM.

Description :
    - Installe les paquets nécessaires pour intégrer un client au serveur LDAP.
    - Configure le fichier `/etc/nslcd.conf` pour se connecter au serveur LDAP.
    - Modifie le fichier `/etc/pam.d/common-session` pour créer des répertoires personnels automatiquement.
    - Met à jour les fichiers `/etc/nsswitch.conf` pour utiliser LDAP pour la gestion des utilisateurs, groupes et mots de passe.

Options :
    -h, --help        Affiche ce message d'aide.

Note :
    Le serveur LDAP doit être opérationnel et accessible depuis ce client pour que la configuration fonctionne correctement.
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

DEBIAN_FRONTEND=noninteractive apt-get install -y libnss-ldapd libpam-ldapd ldap-utils

cat <<EOF |  tee /etc/nslcd.conf > /dev/null
uid nslcd
gid nslcd
uri ldap://192.168.65.3
base dc=amerique,dc=iut
binddn cn=admin,dc=amerique,dc=iut
bindpw azerty
EOF

if ! grep -q "pam_mkhomedir.so" /etc/pam.d/common-session; then
    echo "session required pam_mkhomedir.so skel=/etc/skel umask=0022" >> /etc/pam.d/common-session
fi

sed -i 's/^passwd:.*/passwd:         files ldap/' /etc/nsswitch.conf
sed -i 's/^group:.*/group:          files ldap/' /etc/nsswitch.conf
sed -i 's/^shadow:.*/shadow:         files ldap/' /etc/nsswitch.conf
sed -i 's/^gshadow:.*/gshadow:        files ldap/' /etc/nsswitch.conf

systemctl restart nscd nslcd