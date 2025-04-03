#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: destroy_user [OPTIONS]

Résumé :
    Ce script permet de supprimer un utilisateur de l'annuaire LDAP et de le retirer de groupes spécifiques.

Description :
    - Recherche l'utilisateur dans LDAP à l'aide de son UID.
    - Retire l'utilisateur des groupes prédéfinis.
    - Supprime l'utilisateur de l'annuaire après confirmation.

Options:
    -h, --help      Affiche ce message d'aide.
    
Groupes spécifiques :
    - cn=employerinfo
    - cn=employerproduction
    - cn=employeradministratif
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

# Configuration LDAP
LDAP_SERVER="ldap://192.168.65.3"
LDAP_BIND_DN="cn=admin,dc=amerique,dc=iut"
LDAP_BIND_PW="azerty"
BASE_DN="dc=amerique,dc=iut"

# Demander l'UID de l'utilisateur à supprimer
read -p "Entrez l'UID de l'utilisateur à supprimer (exemple : amber.head) : " uid

# Rechercher le DN complet de l'utilisateur
USER_DN=$(ldapsearch -x -H "$LDAP_SERVER" -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -b "$BASE_DN" "(uid=$uid)" dn | grep "^dn: " | awk '{print $2}')

# Vérifier si le DN a été trouvé
if [ -z "$USER_DN" ]; then
    echo "Erreur : L'utilisateur $uid n'existe pas dans LDAP. Assurez-vous que l'UID est correct."
    exit 1
fi

echo "Utilisateur trouvé : $USER_DN"

# Confirmation de la suppression
read -p "Êtes-vous sûr de vouloir supprimer l'utilisateur $uid ? (oui/non) : " confirm
if [[ "$confirm" != "oui" ]]; then
    echo "Opération annulée."
    exit 1
fi

# GID des groupes spécifiques
GROUP_1="3001"
GROUP_2="3002"
GROUP_3="3003"

# Retirer l'utilisateur des groupes spécifiques
echo "Retrait de l'utilisateur $uid du groupe $GROUP_1..."
MOD_LDIF_FILE="/tmp/remove_${uid}_from_group1.ldif"
cat > "$MOD_LDIF_FILE" <<EOL
dn: cn=employerinfo,ou=Groups,dc=amerique,dc=iut
changetype: modify
delete: memberUid
memberUid: $uid
EOL
ldapmodify -x -H "$LDAP_SERVER" -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -f "$MOD_LDIF_FILE" > /dev/null 2>&1
rm -f "$MOD_LDIF_FILE"

echo "Retrait de l'utilisateur $uid du groupe $GROUP_2..."
MOD_LDIF_FILE="/tmp/remove_${uid}_from_group2.ldif"
cat > "$MOD_LDIF_FILE" <<EOL
dn: cn=employerproduction,ou=Groups,dc=amerique,dc=iut
changetype: modify
delete: memberUid
memberUid: $uid
EOL
ldapmodify -x -H "$LDAP_SERVER" -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -f "$MOD_LDIF_FILE" > /dev/null 2>&1
rm -f "$MOD_LDIF_FILE"

echo "Retrait de l'utilisateur $uid du groupe $GROUP_3..."
MOD_LDIF_FILE="/tmp/remove_${uid}_from_group3.ldif"
cat > "$MOD_LDIF_FILE" <<EOL
dn: cn=employeradministratif,ou=Groups,dc=amerique,dc=iut
changetype: modify
delete: memberUid
memberUid: $uid
EOL
ldapmodify -x -H "$LDAP_SERVER" -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -f "$MOD_LDIF_FILE" > /dev/null 2>&1
rm -f "$MOD_LDIF_FILE"

# Supprimer l'utilisateur de LDAP
echo "Suppression de l'utilisateur $uid..."
ldapdelete -x -H "$LDAP_SERVER" -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" "$USER_DN"
if [ $? -eq 0 ]; then
    echo "Utilisateur $uid supprimé avec succès."
else
    echo "Erreur lors de la suppression de l'utilisateur $uid."
fi
