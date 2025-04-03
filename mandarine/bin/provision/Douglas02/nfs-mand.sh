#!/bin/bash

# Afficher l'aide si -h ou --help est passé en argument
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Ce script configure un serveur NFS pour partager des répertoires spécifiques."
    echo
    echo "Usage : $0"
    echo
    echo "Le script effectue les actions suivantes :"
    echo "  - Met à jour les paquets et installe le serveur NFS (nfs-kernel-server)."
    echo "  - Configure des routes réseau nécessaires pour accéder à d'autres sous-réseaux."
    echo "  - Configure les serveurs DNS en modifiant /etc/resolv.conf."
    echo "  - Crée les répertoires NFS à partager (/srv/nfs/home/administratif et /srv/nfs/home/informatique)."
    echo "  - Définit les permissions appropriées pour ces répertoires."
    echo "  - Configure les règles d'exports NFS dans /etc/exports."
    echo "  - Redémarre le service NFS pour appliquer les changements."
    exit 0
fi

# Mettre à jour les paquets et installer le serveur NFS
apt-get update
apt-get install -qy nfs-kernel-server

# Configurer les routes réseau
ip r add 10.0.0.0/8 via 192.168.57.1 dev eth1
ip r add 192.168.56.0/22 via 192.168.57.1 dev eth1

# Configurer les serveurs DNS
cat << DNS > /etc/resolv.conf
nameserver 10.192.0.2
DNS

# Créer les répertoires NFS à partager
mkdir -p /srv/nfs/home/administratif /srv/nfs/home/informatique

# Configurer les permissions
chown vagrant:vagrant /srv/nfs/home/administratif /srv/nfs/home/informatique
chmod 777 /srv/nfs/home/administratif /srv/nfs/home/informatique

# Configurer les règles d'exports NFS
cat <<-AZE >> /etc/exports
/srv/nfs/ *(rw,sync,no_subtree_check,no_root_squash,fsid=0)
/srv/nfs/home/informatique 192.168.57.0/24(rw,sync,no_subtree_check,no_root_squash)
/srv/nfs/home/administratif 192.168.58.0/24(rw,sync,no_subtree_check,no_root_squash)
AZE

# Redémarrer le service NFS
systemctl restart nfs-server