#!/bin/bash

LDAP_SERVER="ldap://192.168.57.4"
BASE_DN="dc=mandarine,dc=iut"
BIND_DN="cn=admin,dc=mandarine,dc=iut"
BIND_PASSWORD="admin"

# Affiche l'aide si -h ou --help est passé en argument
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Ce script ajoute un utilisateur LDAP dans une OU spécifique ('users-informatique' ou 'users-administratif')."
    echo
    echo "Usage : $0 [option]"
    echo "Options :"
    echo "  -h, --help    Affiche cette aide."
    echo
    echo "L'utilisateur sera invité à entrer l'UID, choisir un groupe (OU), et définir un mot de passe."
    echo "Un UID unique sera généré automatiquement, et l'utilisateur sera ajouté dans l'OU choisie."
    exit 0
fi

# Lecture des informations utilisateur
read -p "Entrez l'UID de l'utilisateur (par exemple : john.doe) : " USER_UID

echo "Choisissez l'OU (groupe) de l'utilisateur :"
echo "1) users-informatique"
echo "2) users-administratif"
read -p "Votre choix (1 ou 2) : " OU_CHOICE

if [ "$OU_CHOICE" -eq 1 ]; then
  OU="users-informatique"
  GID_NUMBER=100
  HOME_DIR="/home/informatique"
elif [ "$OU_CHOICE" -eq 2 ]; then
  OU="users-administratif"
  GID_NUMBER=200
  HOME_DIR="/home/administratif"
else
  echo "Choix invalide. Veuillez relancer le script."
  exit 1
fi

read -s -p "Entrez le mot de passe pour l'utilisateur : " USER_PASSWORD
echo
read -s -p "Confirmez le mot de passe : " CONFIRM_PASSWORD
echo

if [ "$USER_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
  echo "Les mots de passe ne correspondent pas. Veuillez réessayer."
  exit 1
fi

# Générer un UID unique
UID_NUMBER=$((10000 + RANDOM % 90000))

# Générer d'autres attributs automatiquement
CN=$(echo "$USER_UID" | sed 's/\./ /g' | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2)) " " toupper(substr($2,1,1)) tolower(substr($2,2))}')
GIVEN_NAME=$(echo "$USER_UID" | cut -d'.' -f1 | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}')
SN=$(echo "$USER_UID" | cut -d'.' -f2 | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}')
EMAIL="$USER_UID@mandarine.iut"

# Construire l'entrée LDAP
USER_LDIF=$(cat <<EOF
dn: uid=$USER_UID,ou=$OU,dc=mandarine,dc=iut
uid: $USER_UID
cn: $CN
givenName: $GIVEN_NAME
sn: $SN
uidNumber: $UID_NUMBER
gidNumber: $GID_NUMBER
loginShell: /bin/bash
homeDirectory: $HOME_DIR/$USER_UID
mail: $EMAIL
objectClass: top
objectClass: person
objectClass: posixAccount
objectClass: shadowAccount
objectClass: organizationalPerson
objectClass: inetOrgPerson
userPassword: $USER_PASSWORD
EOF
)

echo "L'entrée LDAP suivante sera ajoutée :"
echo "$USER_LDIF"

read -p "Confirmez-vous l'ajout de cet utilisateur ? (oui/non) : " CONFIRMATION
if [[ "$CONFIRMATION" != "oui" ]]; then
  echo "Ajout annulé."
  exit 0
fi

# Ajouter l'utilisateur à LDAP
echo "$USER_LDIF" | ldapadd -x -H "$LDAP_SERVER" -D "$BIND_DN" -w "$BIND_PASSWORD"

if [ $? -eq 0 ]; then
  echo "Utilisateur '$USER_UID' ajouté avec succès dans '$OU'."
else
  echo "Erreur lors de l'ajout de l'utilisateur '$USER_UID'."
  exit 1
fi