## Architecture NFS

Le système NFS est conçu pour partager des répertoires entre plusieurs machines. Il s’appuie sur un serveur qui gère les partages et des clients qui accèdent à ces partages.

### Serveur NFS
- Exporte un répertoire pour qu’il soit accessible aux clients. Cette configuration se fait dans le fichier /etc/exports.
- Exemple de configuration : 

```bash
/srv/nfs/ *(rw,sync,no_subtree_check,no_root_squash,fsid=0)
/srv/nfs/home/informatique 192.168.57.0/24(rw,sync,no_subtree_check,no_root_squash)
/srv/nfs/home/administratif 192.168.58.0/24(rw,sync,no_subtree_check,no_root_squash)
```

Bien sur les repertoires de montage doivent avoir été crée bien avant , cela est fait pour notre part dans le script de déploiement du serveur nfs : 

```bash
mkdir -p /srv/nfs/home/administratif /srv/nfs/home/informatique
chown vagrant:vagrant /srv/nfs/home/administratif /srv/nfs/home/informatique
chmod 777 /srv/nfs/home/administratif /srv/nfs/home/informatique
```

Les droits sur les repertoires doivent etre aussi ajuster pour permettre de garder une confidentialité sur nos fichier et de ne pas pouvoir avoir acces au fichier d'autres personnes.

### Client NFS

- Monte les répertoires partagés à l’aide de la commande mount ou via une entrée dans /etc/fstab pour un montage automatique.

Pour notre part on automatise cela dans un fichier nommé  `client_nfs.sh` , ce script permet donc en se basant sur la plage ip de la machine de monter le repertoire correspondant au réseau dans lequelle se trouve la machine , donc soit sur le réseaux informatique , soit sur le réseau administratif.

## Scripts de configuration

### nfs-mand.sh
Ce script configure le serveur NFS en automatisant les étapes suivantes :

- Installation du paquet nfs-kernel-server.
- Configuration des partages dans /etc/exports.
- Redémarrage du service NFS pour appliquer les modifications.

```bash
  apt-get install -qy nfs-kernel-server 

  mkdir -p /srv/nfs/home/administratif /srv/nfs/home/informatique

  chown vagrant:vagrant /srv/nfs/home/administratif /srv/nfs/home/informatique
  chmod 755 /srv/nfs/home/administratif /srv/nfs/home/informatique

  cat <<-AZE >> /etc/exports
    /srv/nfs/ *(rw,sync,no_subtree_check,no_root_squash,fsid=0)
    /srv/nfs/home/informatique 192.168.57.0/24(rw,sync,no_subtree_check,no_root_squash)
    /srv/nfs/home/administratif 192.168.58.0/24(rw,sync,no_subtree_check,no_root_squash)
  AZE
```

### client-nfs.sh
Automatise la configuration des clients NFS :

- Installation du paquet nfs-common pour activer le support NFS sur les clients.
- Montage des répertoires partagés sur le serveur.


```bash
  apt-get install nfs-common -y

  IP=$(ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+\.\d+\.\d+')

  if [[ "$IP" == "192.168.57" ]]; then
      mkdir -p /home/informatique
      echo "192.168.57.3:/srv/nfs/home/informatique /home/informatique nfs rw,sync,no_subtree_check,no_root_squash 0 0" >> /etc/fstab
      mount -t nfs 192.168.57.3:/srv/nfs/home/informatique /home/informatique
  elif [[ "$IP" == "192.168.58" ]]; then
      mkdir -p /home/administratif
      echo "192.168.57.3:/srv/nfs/home/administratif /home/administratif nfs rw,sync,no_subtree_check,no_root_squash 0 0" >> /etc/fstab
      mount -t nfs 192.168.57.3:/srv/nfs/home/administratif /home/administratif
  fi
```

Ce script se basera donc sur la plage ip afin de definire si la machine fait partit du réseau admin ou du réseau informatique. Apres cela il montera le répertoire approprié pour chaque machine.

Cette liaison permettra donc a tout les repertoires de utilisateur info ou dmin d'etre directement connecter au nfs.

---

# Architecture virtuelle avec Vagrant

Le fichier Vagrantfile définit l’architecture de l’infrastructure virtuelle. Voici les machines et leurs rôles :

- Serveur NFS : Fournit les répertoires partagés.
- Clients : Machines configurées pour accéder aux partages NFS.

Chaque machine est provisionnée automatiquement avec les scripts correspondants, permettant un déploiement rapide et cohérent.

---
