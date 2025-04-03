# Serveur Backup

## Configuration du vagrant pour le serveur de backup

### Configuration du réseau :

    La machine backup obtient l'adresse IP 192.168.57.9 sur un réseau public via un pont (bridge) sur l'interface enp3s0.

### Configuration du disque virtuel :

    Un disque dur virtuel est créé avec une taille de 20 Go sous VirtualBox (fichier poste1_disk1.vdi), puis il est attaché à la machine virtuelle.

### Provisionnement initial :

    Le nom d'hôte de la machine est défini sur backup.
    Le fichier /etc/hosts est modifié pour ajouter l'entrée 127.0.0.1 localhost backup.
    Un fichier de configuration SSH est copié dans le répertoire ~/.ssh/config.
    Une tâche cron est ajoutée pour exécuter un script save.sh tous les vendredis à 23h00 (0 23 * * 5).
    Les clés SSH sont copiées dans le fichier /root/.ssh/authorized_keys pour permettre une connexion SSH sans mot de passe.
    Les sources APT sont mises à jour pour inclure les dépôts Debian bookworm.

### Installation des outils nécessaires :

    Les paquets bzip2, rsync, dump, parted sont installés, qui sont généralement utilisés pour la gestion des sauvegardes et des partitions.

### Montage d'un disque supplémentaire :

    Un script mount_disk.sh est exécuté pour monter un disque supplémentaire.

## Script backup

### mount_disk.sh

Ce script permet d'automatiser le montage de disque virtuels sur le serveur de backup.

```bash
sudo mkfs.ext4 /dev/sdb
sudo mkdir -p /mnt/data
sudo mount /dev/sdb /mnt/data
```

L'utilisation de disque virtuels va permettre de pouvoir stocker les backups a l'exterieur et que cela ne soit pas dependant du disque de la vm.
Ce qui permettra plus tard de pouvoir remonter un serveur sur ce disque et de pouvoir y stocké nos backup.


### save.sh

Script permet de pouvoir créer une sauvegarde sur les serveurs ldap et nfs via les commande suivantes:

```bash
ssh srvnfs "sudo dump -0u -f - /" | bzip2 > /mnt/data/srvnfs.1.bz2
ssh ldap "sudo dump -0u -f - /" | bzip2 > /mnt/data/ldap.1.bz2
```
Ce script crée des sauvegardes compressées (bzip2) des systèmes de fichiers racine de deux serveurs distants (srvnfs et ldap) et les stocke localement.

### restauration.sh

Ce script va permettre la restauration des backup faites plutot.

```bash
bzip2 -dc /mnt/data/srvnfs.1.bz2 | ssh srvnfs "cd /; restore -xof -"
bzip2 -dc /mnt/data/ldap.1.bz2 | ssh srvnfs "cd /; restore -xof -"
``` 

Ce script extrait des fichiers de sauvegarde compressés avec bzip2 et les restaure sur un serveur distant via SSH.


