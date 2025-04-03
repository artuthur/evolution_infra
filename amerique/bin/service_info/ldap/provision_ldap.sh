#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: provision_ldap [OPTIONS]

Résumé :
    Ce script configure automatiquement un serveur LDAP avec des utilisateurs et des groupes prédéfinis.

Description :
    - Installe et configure `slapd` (serveur LDAP) ainsi que des utilitaires LDAP comme `ldap-utils`.
    - Prépare une base de données LDAP et importe les données depuis des fichiers `.ldif`.
    - Configure le mot de passe root LDAP défini dans le script.
    - Ajoute des utilisateurs, groupes et définitions d'accès pour le domaine `amerique.iut`.

Options:
    -h, --help        Affiche ce message d'aide.

Note :
    Veillez à configurer les fichiers nécessaires dans le répertoire `/home/vagrant/ldap/` avant d'exécuter ce script.
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

LDAP_PASSWORD="azerty"  # Mot de passe LDAP défini ici

# Mise à jour des paquets et installation des utilitaires LDAP
 apt-get update
 DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils libnss-ldap libpam-ldap

# Création du répertoire de stockage des données LDAP
 mkdir -p /srv/ldap/ameriqueiut
 chown openldap:openldap /srv/ldap/ameriqueiut

# Copier les fichiers nécessaires dans le répertoire
 cp -f /home/vagrant/ldap/* /srv/ldap/ameriqueiut

# Se rendre dans le répertoire des données LDAP
cd /srv/ldap/ameriqueiut

# Remplacer le mot de passe dans le fichier base.ldif
# Utilisation d'un sed pour remplacer le mot de passe dans le fichier base.ldif
 sed -i "s|^olcRootPW:.*|olcRootPW: $LDAP_PASSWORD|" /srv/ldap/ameriqueiut/base.ldif 

# Ajouter la base de données LDAP avec le fichier base.ldif modifié
 ldapadd -Y EXTERNAL -H ldapi:/// -f base.ldif

# Ajouter les utilisateurs et autres données avec iut.ldif
echo "$LDAP_PASSWORD" |  ldapadd -x -H ldapi:/// -D "cn=admin,dc=amerique,dc=iut" -w "$LDAP_PASSWORD" -f iut.ldif

# Ajouter les droits d'accès avec droit_acces.ldif
 ldapadd -Y EXTERNAL -H ldapi:/// -f droit_acces.ldif

# Ajouter les index avec index.ldif
 ldapadd -Y EXTERNAL -H ldapi:/// -f index.ldif

# Ajouter d'autres données nécessaires avec arbor.ldif
echo "$LDAP_PASSWORD" |  ldapadd -x -H ldapi:/// -D "cn=admin,dc=amerique,dc=iut" -w "$LDAP_PASSWORD" -f /home/vagrant/ldap/arbor.ldif 

# Ajout de l'objet groups 
echo "$LDAP_PASSWORD" |  ldapadd -x -H ldapi:/// -D "cn=admin,dc=amerique,dc=iut" -w "$LDAP_PASSWORD" -f /home/vagrant/ldap/groups.ldif

# Ajout des différents groupes admin,info,prod
echo "$LDAP_PASSWORD" |  ldapadd -x -H ldapi:/// -D "cn=admin,dc=amerique,dc=iut" -w "$LDAP_PASSWORD" -f /home/vagrant/ldap/amerique_groups.ldif


# Ajout des différents utilisateurs
echo "$LDAP_PASSWORD" |  ldapadd -x -H ldapi:/// -D "cn=admin,dc=amerique,dc=iut" -w "$LDAP_PASSWORD" -f /home/vagrant/ldap/create_default_users.ldif

echo -e "nameserver 10.64.0.2\nnameserver 10.64.0.5" |  tee /etc/resolv.conf > /dev/null

ip route add 192.168.0.0/16 dev eth1 2> /dev/null
ip route add 10.0.0.0/8 dev eth1 2> /dev/null