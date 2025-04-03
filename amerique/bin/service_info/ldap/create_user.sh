#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: create_user [OPTIONS]

Résumé :
    Ce script permet de créer un nouvel utilisateur dans l'annuaire LDAP et de l'ajouter à un groupe spécifique (cf. nos différents services).

Description :
    - Demande les informations de l'utilisateur (nom, UID, mot de passe).
    - Propose une sélection de groupes pour associer l'utilisateur.
    - Génère un fichier LDIF contenant les informations de l'utilisateur.
    - Ajoute l'utilisateur à l'annuaire LDAP.
    - Ajoute l'utilisateur au groupe sélectionné dans LDAP.
    - Nettoie les fichiers LDIF temporaires une fois les opérations terminées.

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

# Configuration LDAP
LDAP_SERVER="ldap://192.168.65.3" # Adresse de notre serveur LDAP
LDAP_BIND_DN="cn=admin,dc=amerique,dc=iut" # DN de l'utilisateur administrateur
LDAP_BIND_PW="azerty" # Mot de passe de l'utilisateur administrateur
BASE_DN="dc=amerique,dc=iut" # DN de base pour notre annuaire LDAP

# Fonction pour afficher les choix de groupes
choose_group() {
    echo "Choisissez un groupe pour l'utilisateur :"
    echo "1. Utilisateur Informatique"
    echo "2. Utilisateur Administratif"
    echo "3. Utilisateur Production"
    read -p "Entrez le numéro du groupe (1, 2 ou 3) : " group_choice

    case $group_choice in
        1)
            GROUP="Informatique"
            GROUP_DN="cn=employerinfo,ou=Groups,$BASE_DN"
            ;;
        2)
            GROUP="Administratif"
            GROUP_DN="cn=employeradministratif,ou=Groups,$BASE_DN"
            ;;
        3)
            GROUP="Production"
            GROUP_DN="cn=employeproduction,ou=Groups,$BASE_DN"
            ;;
        *)
            echo "Choix invalide. Veuillez réessayer."
            choose_group
            ;;
    esac
}

# Demander les informations de l'utilisateur
read -p "Entrez le nom complet de l'utilisateur (exemple : John Doe): " full_name
read -p "Entrez l'UID de l'utilisateur (exemple : john.doe) : " uid
read -p "Entrez le mot de passe de l'utilisateur : " -s password
echo

# Appeler la fonction pour choisir le groupe
choose_group

# Générer le fichier LDIF pour l'utilisateur
LDIF_FILE="/tmp/${uid}.ldif"
cat > "$LDIF_FILE" <<EOL
dn: uid=$uid,ou=Utilisateurs,ou=$GROUP,$BASE_DN
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
uid: $uid
cn: $full_name
sn: $uid
uidNumber: $(shuf -i 1000-9999 -n 1)
gidNumber: 2001
homeDirectory: /home/$GROUP/$uid
loginShell: /bin/bash
mail: $uid@amerique.iut
userPassword: $password
EOL

# Ajouter l'utilisateur dans LDAP
echo "Ajout de l'utilisateur dans LDAP..."
ldapadd -x -H "$LDAP_SERVER" -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -f "$LDIF_FILE"

if [ $? -eq 0 ]; then
    echo "Utilisateur $uid ajouté avec succès dans le groupe $GROUP."
    
    # Ajouter l'utilisateur au groupe sélectionné
    echo "Ajout de l'utilisateur $uid au groupe $GROUP ($GROUP_DN)..."
    MOD_LDIF_FILE="/tmp/add_${uid}_to_group.ldif"
    cat > "$MOD_LDIF_FILE" <<EOL
dn: $GROUP_DN
changetype: modify
add: memberUid
memberUid: $uid
EOL

    ldapmodify -x -H "$LDAP_SERVER" -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -f "$MOD_LDIF_FILE"

    if [ $? -eq 0 ]; then
        echo "Utilisateur $uid ajouté au groupe $GROUP avec succès."
    else
        echo "Erreur lors de l'ajout de l'utilisateur $uid au groupe $GROUP."
    fi

    # Nettoyer le fichier LDIF
    rm -f "$MOD_LDIF_FILE"
else
    echo "Erreur lors de l'ajout de l'utilisateur $uid."
fi

# Nettoyer le fichier LDIF
rm -f "$LDIF_FILE"
