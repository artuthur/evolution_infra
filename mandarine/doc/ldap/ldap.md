# Architecture LDAP

L’infrastructure LDAP est conçue pour fournir un annuaire centralisé, facilitant la gestion des utilisateurs et des groupes. Voici les composants principaux :

## Fichiers de configuration

### `base.ldif`
Ce fichier contient la configuration de base de l’annuaire LDAP, y compris les noms de domaine et les unités organisationnelles. Les unités organisationnelles permettent de regrouper des objets (par exemple, les utilisateurs et les groupes) dans des catégories logiques. Exemple :

- **Ajout de domaines** : `dc=exemple,dc=com` permet de définir le domaine de l’organisation.
- **Création des unités organisationnelles** :
  - `People` (pour les utilisateurs)
  - `Groups` (pour les groupes)

### `personne.ldif`
Ce fichier décrit les utilisateurs à ajouter à l'annuaire. Chaque utilisateur est associé à des attributs comme :

- **`uid`** : Identifiant unique de l’utilisateur.
- **`cn`** : Nom complet de l’utilisateur.
- **`gidNumber`** : Identifiant du groupe auquel appartient l’utilisateur.

Ce qui donne le fichier base.ldif suivant : 

```ldif
dn: dc=mand,dc=iut
objectClass: organizationalUnit
ou: users

dn: ou=users-administratif,dc=mand,dc=iut
objectclass: organizationalunit
ou: administratif

dn: ou=users-informatique,dc=mand,dc=iut
objectclass: organizationalunit
ou: users-informatique
```

## Utilisation des fichiers LDIF

Pour appliquer les configurations définies dans les fichiers LDIF, vous pouvez utiliser la commande `ldapadd` :

1. **Importer la configuration de base :**
   ```bash
   ldapadd -x -D "cn=admin,dc=exemple,dc=com" -W -f base.ldif
   ``` 
- Ajoutez les utilisateurs spécifiés dans personne.ldif avec une commande similaire.

---

# Scripts de provisionnement

## provision-ldap.sh
Ce script automatise l'installation et la configuration du serveur LDAP. Voici les principales étapes réalisées :

- Installation des paquets nécessaires : slapd (serveur LDAP) et ldap-utils (outils en ligne de commande pour interagir avec le serveur).

  ```bash
    DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils
  ``` 

- Initialisation du serveur LDAP avec les fichiers LDIF comme base.ldif.

  ```bash
    ldapadd -D "cn=admin,dc=mandarine,dc=iut" -w "$PASSWORD" -f /srv/ldap/iut/base.ldif
  ``` 

- Configuration de l’administrateur LDAP pour gérer l’annuaire.

  ```ldif
  dn: uid=admin,ou=users-administratif,ou=users-informatique,dc=mandarine,dc=iut
  objectClass: inetOrgPerson
  objectClass: shadowAccount
  cn: LDAP Admin
  sn: Admin
  uid: admin
  userPassword: admin
  homeDirectory: /home/adminif
  ``` 

Ce script garantit que le serveur est pleinement opérationnel avec une configuration minimale mais fonctionnelle.

## provision-client.sh
Ce script configure les clients pour s’authentifier via le serveur LDAP. Les principales actions incluent :

- Installation des bibliothèques nécessaires, comme libnss-ldap et libpam-ldap.

  ```bash
  DEBIAN_FRONTEND=noninteractive apt install -y libnss-ldap libpam-ldap ldap-utils nscd
  ``` 

- Modification des fichiers de configuration, comme nsswitch.conf, pour inclure LDAP dans la résolution des noms d’utilisateur.

  ```bash
   sed -i 's/^passwd:.*/passwd:         files ldap/' /etc/nsswitch.conf
   sed -i 's/^group:.*/group:          files ldap/' /etc/nsswitch.conf
   sed -i 's/^shadow:.*/shadow:         files ldap/' /etc/nsswitch.conf
  ``` 
Ces lignes permette de l'automatiser dans le script.

- Mise à jour des fichiers PAM (Pluggable Authentication Modules) pour activer l’authentification via LDAP mlais aussi pour permettre la creation de repertoire lors de la premiere connexion  de l'utilisateur.

  ```pam
    session     required      pam_mkhomedir.so skel=/etc/skel umask=0022
  ``` 

---

# Gestion des autorisations

## autorisation_login.sh

Ce script permet de contrôler les accès des utilisateurs aux machines clientes en fonction de leur appartenance à des groupes. Il s’intègre directement dans la configuration PAM pour appliquer des règles strictes d’authentification. 

Exemples de fonctionnalités :
- Autoriser uniquement les utilisateurs avec un gidNumber spécifique.
- Bloquer l’accès à certaines machines en fonction de groupes prédéfinis.


# Script ldap

## create_user.sh

Script qui permet la creation d'utilisateur dans la base ldap.

Celui va demander des entrée utilisateurs afin de pouvoir créer un utilisateur qui respect tout nos demande tels que le mot de passe , le nom , le prenom , le groupe (info/admin).
Ce script verifie aussi les entrée uilisateurs et verifie aussi si l'utilisateur existe dans la base ldif.

Une fois toutes les entrées remplit l'utilisateur est stocké dans une variable `USER_LDIF` et est montrer a l'utilisateur pour qu'il puisse verifier que tout les attributs donnés sont bons.

Ensuite via cette variable il va ajouter l'utilisateur a la base ldap : 

```bash
  echo "$USER_LDIF" | ldapadd -x -H "$LDAP_SERVER" -D "$BIND_DN" -w "$BIND_PASSWORD"
```

Le script est sctocké dans `usr/local/sbin` ce qui permet d'etre utiliser seulement par root ou par les utilisateur faisant partit du groupe sudoer.


## delete_user.sh

Ce script permet la suppression d'un utilisateur de la base ldif.

Ce script va demander une entrée utilisateur et demandé le login de l'utilisateur a supprimé.

Apres cela il va question la base ldap afin de verifier si l'utilisateur existe dans la base ldap.
```bash
  USER_DN=$(ldapsearch -x -LLL -H "$LDAP_SERVER" -D "$BIND_DN" -w "$BIND_PASSWORD" -b "$BASE_DN" "(uid=$USER_UID)" dn | grep "^dn: " | sed 's/^dn: //')
```
A la fin il vous demandera une derniere entrée utilisateur pour savoir si vous voulez vraiment supprimer l'utilisateur et le supprimera : 

```bash 
  ldapdelete -x -H "$LDAP_SERVER" -D "$BIND_DN" -w "$BIND_PASSWORD" "$USER_D
```

## change_password.sh

Ce script permet le changement de mot de passe d'un utilisateur ldap.

Celui ci fonctionne un peu comme `delete_user.sh` et va permettre de retrouver un utilisateur dans la base ldap via l'entré utilisateur qui demande le login.

Une fois l'utilisateur trouvé , le script va vous demander a 2 reprise d'entré le mot de passe et va comparé les 2 entré pour voir qui sont bien similaire.

Une fois cette verification faite le script fera une requetes a la base ldap afin de changer le mot de passe de l'utilisateur entré précédement.

```bash 
  ldappasswd -x -H "$LDAP_SERVER" -D "$BIND_DN" -w "$BIND_PASSWORD" -s "$NEW_PASSWORD" "$USER_DN"
```

Bien sur tout ces script utilise les varibales suivantes : 

```bash 
  LDAP_SERVER="ldap://192.168.57.4"
  BASE_DN="dc=mandarine,dc=iut"
  BIND_DN="cn=admin,dc=mandarine,dc=iut"
  BIND_PW="admin"
```
Ces variables vont donc permettre de pouvoir se connecter au serveurs ldap et donc de permettre au script de fonctionner comme il faut.

# Architecture virtuelle avec Vagrant

Le fichier Vagrantfile définit l’architecture de l’infrastructure virtuelle. Voici les machines et leurs rôles :

- Serveur LDAP : Gère l’annuaire des utilisateurs.
- Clients : Machines configurées pour utiliser LDAP.

Chaque machine est provisionnée automatiquement avec les scripts correspondants, permettant un déploiement rapide et cohérent.

---