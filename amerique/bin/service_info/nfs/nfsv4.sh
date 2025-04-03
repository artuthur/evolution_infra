#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: nfsv4 [OPTIONS]

Résumé :
    Ce script configure un serveur NFSv4 et crée trois répertoires partagés (cf. nos différents services) avec les bonnes permissions.

Description :
    - Installe le serveur NFS.
    - Crée trois répertoires partagés : /home/Informatique, /home/Administratif, et /home/Production.
    - Attribue des permissions d'accès en lecture-écriture à tous les utilisateurs (chmod 777) pour ces répertoires.
    - Configure les options d'exportation NFS pour rendre ces répertoires accessibles depuis n'importe quel client.
    - Configure le serveur NFS pour n'activer que la version 4 du protocole NFS.
    - Redémarre le service NFS pour appliquer la configuration.

Options :
    -h, --help        Affiche ce message d'aide.

Note :
    Assurez-vous que le serveur NFS est bien configuré pour accepter des connexions depuis les clients autorisés.
    Le script suppose que les répertoires mentionnés sont créés sur le serveur local.
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


apt-get install -qy nfs-kernel-server

mkdir -p /home/Informatique /home/Administratif /home/Production

chmod 777 /home/Informatique /home/Administratif /home/Production

cat <<EOF |  tee /etc/exports
/home/Informatique *(rw,sync,no_subtree_check,root_squash)
/home/Administratif *(rw,sync,no_subtree_check,root_squash)
/home/Production *(rw,sync,no_subtree_check,root_squash)
EOF

exportfs -arv

cat <<EOF |  tee /etc/nfs.conf
[nfsd]
vers4=y
vers3=n
vers2=n
EOF

systemctl restart nfs-kernel-server