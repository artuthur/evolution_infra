#!/bin/bash

LDAP_SERVER="ldap://192.168.57.4"
BASE_DN="dc=mandarine,dc=iut"
BIND_DN="cn=admin,dc=mandarine,dc=iut"
BIND_PASSWORD="admin"

# Affiche l'aide si -h ou --help est passé en argument
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Ce script permet de changer le mot de passe d'un utilisateur LDAP."
    echo
    echo "Usage : $0 [option]"
    echo "Options :"
    echo "  -h, --help    Affiche cette aide."
    echo
    echo "Vous serez invité à entrer l'UID de l'utilisateur, puis le nouveau mot de passe."
    echo "Le script utilise les paramètres LDAP définis pour effectuer les modifications."
    exit 0
fi

# Lecture de l'UID de l'utilisateur
read -p "Entrez l'UID de l'utilisateur pour changer le mot de passe : " USER_UID

# Recherche du DN de l'utilisateur
USER_DN=$(ldapsearch -x -LLL -H "$LDAP_SERVER" -D "$BIND_DN" -w "$BIND_PASSWORD" -b "$BASE_DN" "(uid=$USER_UID)" dn | grep "^dn: " | sed 's/^dn: //')

if [ -z "$USER_DN" ]; then
  echo "Utilisateur avec UID '$USER_UID' introuvable."
  exit 1
fi

echo "Utilisateur trouvé : $USER_DN"

# Demande du nouveau mot de passe
read -s -p "Entrez le nouveau mot de passe : " NEW_PASSWORD
echo
read -s -p "Confirmez le nouveau mot de passe : " CONFIRM_PASSWORD
echo

if [ "$NEW_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
  echo "Les mots de passe ne correspondent pas. Veuillez réessayer."
  exit 1
fi

# Changement du mot de passe via ldappasswd
ldappasswd -x -H "$LDAP_SERVER" -D "$BIND_DN" -w "$BIND_PASSWORD" -s "$NEW_PASSWORD" "$USER_DN"

if [ $? -eq 0 ]; then
  echo "Le mot de passe pour l'utilisateur '$USER_UID' a été changé avec succès."
else
  echo "Erreur lors du changement de mot de passe pour l'utilisateur '$USER_UID'."
  exit 1
fi
