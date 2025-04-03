#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: user-home [OPTIONS]

Ce script automatise la création et la gestion des répertoires NFS des utilisateurs LDAP.

Description :

    - Met à jour le cache LDAP pour garantir la prise en compte des dernières modifications.
    - Crée les répertoires parents spécifiés si nécessaire.
    - Récupère la liste des utilisateurs de chaque groupe associé à un répertoire parent.
    - Crée des répertoires utilisateurs avec les permissions appropriées pour garantir la sécurité des données.
    - Définit le propriétaire et le groupe des répertoires pour correspondre à l'utilisateur et à son groupe.
    - Ignore les répertoires utilisateurs déjà existants pour éviter des conflits ou des pertes de données.

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


# Mettre à jour le cache des groupes
sudo nscd -i group

# Définir les répertoires parents et les groupes associés
declare -A PARENT_DIRS=(
    ["/home/Informatique"]="employerinfo"
    ["/home/Production"]="employerproduction"
    ["/home/Administratif"]="employeradministratif"
)

# Traiter chaque répertoire parent et son groupe associé
for PARENT_DIR in "${!PARENT_DIRS[@]}"; do
    GROUP="${PARENT_DIRS[$PARENT_DIR]}"

    echo "Traitement pour $PARENT_DIR avec le groupe $GROUP"

    # Créer le répertoire parent si nécessaire
    sudo mkdir -p "$PARENT_DIR"
    sudo chmod o+x "$PARENT_DIR"

    # Récupérer les utilisateurs du groupe
    USERS=$(getent group "$GROUP" | cut -d: -f4 | tr ',' ' ')

    # Créer les répertoires pour chaque utilisateur
    for USER in $USERS; do
        USER_DIR="$PARENT_DIR/$USER"

        # Vérifier si le répertoire existe
        if [ ! -d "$USER_DIR" ]; then
            echo "Création du répertoire pour $USER"
            sudo mkdir -p "$USER_DIR"
            sudo chown -R "$USER:$GROUP" "$USER_DIR"
            sudo chmod 700 "$USER_DIR"
        else
            echo "Le répertoire de $USER existe déjà : $USER_DIR"
        fi
    done
done

echo "Configuration terminée."