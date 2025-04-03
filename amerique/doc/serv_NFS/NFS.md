---
title: Mise en place du service NFS
---


### Pourquoi utiliser partager ses répertoires sur le réseau ?

En partageant les répertoires sur le réseau, nous les centralisons pour un accès facile, on permet une collaboration facile entre utilisateurs, également sauvegarder et gérer les données depuis un endroit.

### Pourquoi utiliser NFS v4  ?

Il est plus sécurisé, car c'est un support natif pour Kerberos et TLS, il est plus performant avec une meilleure gestion des caches, il a des fonctionnalités avancées tel que des ACL améliorées ainsi que des verouillages d'état et n'utilise qu'un seul port: TCP 2049.


# Mise en place du service NFS
## Objectif

Configurer un service **NFS (Network File System)** permettant le partage de répertoires entre plusieurs machines de nos différents services.

---

## Étapes de configuration

### 1. Configuration du Serveur NFS

#### Préparation de la machine serveur

**Configurer les partages NFS** :
   
- Installe `nfs-kernel-server`.
- Configure `/etc/exports` pour partager `/home` avec les réseaux autorisés, en l'occurence nos services admin,prod,etc :
```conf
/home/Informatique *(rw,sync,no_subtree_check,root_squash)
/home/Administratif *(rw,sync,no_subtree_check,root_squash)
/home/Production *(rw,sync,no_subtree_check,root_squash)
```

- On crée les répertoires que l'on va partager
```shell
sudo mkdir -p /home/Informatique
sudo mkdir -p /home/Production
sudo mkdir -p /home/Adminstratif
```

- On défini les permissions pour les répertoires
```shell
sudo chmod 755 /home/informatique /home/Administratif /home/Production
```
- On applique les modifications
```shell
sudo exportfs -arv
```
- Applique les changements et redémarre le service NFS.
```shell
sudo systemctl restart nfs-kernel-server
```
- Activation du support NFS v4
```shell
cat <<EOF | sudo tee /etc/nfs.conf
[nfsd]
vers4=y
vers3=n
vers2=n
EOF
```


### 2. Les différentes options utilisées:

rw : Permet aux clients de lire et écrire dans le partage.

sync : Les données sont écrites sur le disque immédiatement, garantissant leur intégrité en cas de panne.

no_subtree_check : Désactive les vérifications sur les sous-répertoires pour améliorer les performances.

root_squash : Empêche le client NFS d'utiliser les privilèges root sur le serveur, renforçant la sécurité.



### 3. Configuration du montage NFS

Sur les postes clients nous ajoutons les points de montage NFS au fichier `/etc/fstab` pour monter automatiquement les répertoires partagés au démarrage :

```bash
echo "<ip du serveur nfs>:/home/Informatique /home/Informatique nfs nfsvers=4 0 0" | sudo tee -a /etc/fstab
echo "<ip du serveur nfs>:/home/Administratif /home/Administratif nfs nfsvers=4 0 0" | sudo tee -a /etc/fstab
echo "<ip du serveur nfs>:/home/Production /home/Production nfs nfsvers=4 0 0" | sudo tee -a /etc/fstab
```

---

### 4. Création des répertoires et montage des partages

Nous créons les répertoires locaux pour chaque point de montage NFS :

```bash
sudo mkdir -p /home/Informatique
sudo mkdir -p /home/Administratif
sudo mkdir -p /home/Production
```

Enfin, nous montons les systèmes de fichiers NFS définis dans `/etc/fstab` avec :

```bash
sudo mount -a
```

Suite à cela, nous pouvons voir que les différents répertoires des services et des utilisateurs ont bien été montés et sont intègres.

Lorsque nous créons un fichier dans un répertoire sur l'un des clients, il apparaît également en partage sur les autres clients et sur le serveur NFS

## Retour au sommaire

- [Retourner au sommaire](../../README.md#documentations---liens-rapide)


