#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: workstation [OPTIONS]

Résumé :
    Ce script configure une station de travail avec un environnement graphique XFCE, les applications firefox (navigateur web) & Thunderbird (client mail) , une connexion LDAP et un montage NFS.

Description :
    - Installe l'environnement graphique XFCE avec les outils associés (xfce4, firefox-esr, thunderbird).
    - Configure le clavier en disposition AZERTY.
    - Ajoute des routes pour les réseaux internes.
    - Installe les paquets nécessaires pour utiliser LDAP et NFS.
    - Configure la connexion à un serveur LDAP pour l'authentification.
    - Configure PAM pour créer automatiquement un répertoire personnel pour les utilisateurs LDAP lors de la connexion.
    - Ajoute les partages NFS pour les répertoires partagés sur le serveur.

Options :
    -h, --help        Affiche ce message d'aide.

Note :
    Ce script suppose que le serveur LDAP est accessible à l'adresse 192.168.65.3 et que les partages NFS sont disponibles à partir de 192.168.65.2.
    Veuillez vérifier ces adresses et ajuster la configuration du réseau en conséquence.

    Le script configure également les DNS pour utiliser 10.64.0.2 et 10.64.0.5 et protège ces configurations contre toute modification.
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

apt-get update -y
apt-get install -y xfce4 xfce4-goodies
apt-get install -y virtualbox-guest-x11
apt-get install -y firefox-esr thunderbird


# Configuration du clavier en AZERTY
sed -i 's/XKBLAYOUT="us"/XKBLAYOUT="fr"/' /etc/default/keyboard
dpkg-reconfigure -f noninteractive keyboard-configuration

ip route add 192.168.0.0/16 dev eth1
ip route add 10.0.0.0/8 dev eth1

apt-get install nfs-common -y
apt-get install tree -y
DEBIAN_FRONTEND=noninteractive apt install -y libnss-ldapd libpam-ldapd ldap-utils

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

echo "192.168.65.2:/home/Informatique /home/Informatique nfs nfsvers=4 0 0" |  tee -a /etc/fstab
echo "192.168.65.2:/home/Administratif /home/Administratif nfs nfsvers=4 0 0" |  tee -a /etc/fstab
echo "192.168.65.2:/home/Production /home/Production nfs nfsvers=4 0 0" |  tee -a /etc/fstab

mkdir -p /home/Informatique
mkdir -p /home/Administratif
mkdir -p /home/Production

mount -a

reboot

ip route add 192.168.0.0/16 dev eth1 2> /dev/null
ip route add 10.0.0.0/8 dev eth1 2> /dev/null


echo -e "nameserver 10.64.0.2\nnameserver 10.64.0.5" |  tee /etc/resolv.conf > /dev/null
chattr +i /etc/resolv.conf


