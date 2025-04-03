# Mise en place du service LDAP

## Vagrantfile et provisionning

Nous avons automatisé le déploiement de notre service LDAP via le Vagrantfile ([Vagrantfile](../../bin/service_info/ldap/Vagrantfile)) ci-dessous ainsi qu'un [script de provision](../../bin/service_info/ldap/provision_ldap.sh). Le script `provision_ldap.sh` permet la mise en place de notre service LDAP avec :

- **Installation des paquets nécessaires** ;
- **Création de la base de données LDAP** ;
- **Ajout de la racine** (via `iut.ldif`) ;
- **Ajout d'utilisateurs et de groupes** (via des fichiers LDIF dédiés) ;
- **Configuration des droits d'accès** ;
- **Ajout d'index** pour optimiser les performances des recherches.

---

## Architecture de notre service LDAP

L'architecture de notre service LDAP suit une structure hiérarchique, organisée autour d'une racine de type *domain component* (DC). Voici une description des principaux composants :

### Racine du domaine

- **Base DN** : `dc=amerique,dc=iut`
- Cette racine représente l'organisation principale. Elle est créée avec le fichier `iut.ldif` et est définie comme le point d'entrée de notre base LDAP.

### Organisation

Sous la racine, une organisation est définie avec les informations suivantes :
- **ObjectClass** : `organization`, `dcObject`
- **Domaine** : `amerique.iut` (attribut `o`)
- **DC** : `amerique` et `iut`

### Unités Organisationnelles (OU)

Les unités organisationnelles permettent de structurer les différentes entités ou départements de notre domaine LDAP. Bien qu'elles ne soient pas explicitement listées dans cette documentation, elles peuvent inclure des entités comme :

- `ou=Utilisateurs`
- `ou=Groupes`
- `ou=Informatique`

Ces unités organisationnelles facilitent la gestion et la recherche des objets (utilisateurs, groupes, etc.) dans la base LDAP.

### Utilisateurs

Les utilisateurs sont définis avec plusieurs attributs dans la base LDAP. Un exemple est fourni dans le fichier `create_default_users.ldif` :

- **Base DN de l'utilisateur** : `uid=jean.dupont,ou=Utilisateurs,ou=Informatique,dc=amerique,dc=iut`
- **ObjectClasses** :
  - `inetOrgPerson` : pour les informations personnelles (nom, prénom, email).
  - `posixAccount` : pour les informations système nécessaires à une intégration UNIX (UID, GID, répertoire personnel, shell).
  - `shadowAccount` : pour les informations liées au mot de passe et à la sécurité.

### Groupes

Les groupes d'utilisateurs peuvent également être définis dans des unités organisationnelles spécifiques, avec des attributs comme :

- `gidNumber` : identifiant du groupe.
- `memberUid` : membres du groupe.

---

## Installation

On installe le serveur LDAP via le gestionnaire de paquets. Les commandes suivantes permettent de télécharger et configurer les paquets nécessaires :

```bash
apt-get -qy update
apt-get -qy install slapd ldap-utils
apt-get -qy clean
```

---

## Configuration

### Environnement

On crée le répertoire de stockage des données LDAP pour garantir une séparation propre des données de configuration et des données utilisateur :

```bash
sudo mkdir -p /srv/ldap/ameriqueiut
sudo chown openldap:openldap /srv/ldap/ameriqueiut
```

---

### Configuration des fichiers LDIF

Les fichiers LDIF permettent d'ajouter et de configurer des éléments dans le service LDAP.

#### Fichier de base de données `base.ldif`

Ce fichier configure la base de données LDAP (MDB) et définit les paramètres essentiels, notamment :

- Répertoire des données (`olcDbDirectory`) : `/srv/ldap/ameriqueiut`
- DN suffixe (`olcSuffix`) : `dc=amerique,dc=iut`
- DN de l'administrateur (`olcRootDN`) : `cn=admin,dc=amerique,dc=iut`
- Mot de passe administrateur (`olcRootPW`) : `azerty` (à remplacer par un mot de passe haché sécurisé).

```ldif
dn: olcDatabase=mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: mdb
olcDbDirectory: /srv/ldap/ameriqueiut
olcSuffix: dc=amerique,dc=iut
olcRootDN: cn=admin,dc=amerique,dc=iut
olcRootPW: azerty
olcAccess: to * by dn="cn=admin,dc=amerique,dc=iut" write by * read
```

On ajoute cette configuration avec la commande :

```bash
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f base.ldif
```

#### Ajout de la racine `iut.ldif`

La racine de la base LDAP est créée pour définir l'organisation et le domaine :

```ldif
dn: dc=amerique,dc=iut
objectClass: dcObject
objectClass: organization
dc: amerique
o: amerique.iut
```

Ajoutez-la avec :

```bash
sudo ldapadd -x -H ldapi:/// -D "cn=admin,dc=amerique,dc=iut" -W -f iut.ldif
```

#### Configuration des droits d'accès `droit_acces.ldif`

Les droits d'accès sont définis pour protéger les données sensibles et permettre un contrôle des autorisations :

```ldif
dn: olcDatabase={2}mdb,cn=config
changetype:  modify
replace: olcAccess
olcAccess: {0}to attrs=userPassword,telephoneNumber,shadowLastChange,email
    by self write
    by anonymous auth
    by * none
olcAccess: {1}to *
    by self write
    by * read
```

Ajoutez-les avec :

```bash
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f droit_acces.ldif
```

#### Configuration des index `index.ldif`

Les index accélèrent les recherches LDAP, par exemple sur les attributs `objectClass` et `uid` :

```ldif
dn: olcDatabase={2}mdb,cn=config
changetype: modify
add: olcDbIndex
olcDbIndex: objectClass eq 
olcDbIndex: uid eq,sub
```

Ajoutez-les avec :

```bash
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f index.ldif
```

#### Ajout d'un groupe `amerique_groups.ldif`

```ldif
dn: ou=Groups,dc=amerique,dc=iut
ou: Groups
objectClass: organizationalUnit

# Groupe Employer Info
dn: cn=employerinfo,ou=Groups,dc=amerique,dc=iut
objectClass: posixGroup
objectClass: top
cn: employerinfo
gidNumber: 3001
memberUid: younes.bensyed
memberUid: arthur.debacq
memberUid: valentin.hebert

# Groupe Employe Production
dn: cn=employeproduction,ou=Groups,dc=amerique,dc=iut
objectClass: posixGroup
objectClass: top
cn: employeproduction
gidNumber: 3002

# Groupe Employer Administratif
dn: cn=employeradministratif,ou=Groups,dc=amerique,dc=iut
objectClass: posixGroup
objectClass: top
cn: employeradministratif
gidNumber: 3003
memberUid: jean.dupont
```

Ajoutez le groupe avec :

```bash
sudo ldapadd -x -H ldapi:/// -D "cn=admin,dc=amerique,dc=iut" -W -f amerique_groups.ldif
```

#### Ajout des utilisateurs par défaut (du groupe amerique) `create_default_users.ldif`

L'exemple ci-dessous crée nos utilisateurs avec nos informations personnelles et nos paramètres système :

```ldif
dn: uid=arthur.debacq,ou=Utilisateurs,ou=Informatique,dc=amerique,dc=iut
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: arthur.debacq
cn: Arthur Debacq
sn: Debacq
givenName: Arthur
displayName: Arthur Debacq
uidNumber: 1002
gidNumber: 2001
homeDirectory: /home/Informatique/arthur.debacq
loginShell: /bin/bash
userPassword: arthur
shadowLastChange: 19000
gecos: Arthur Debacq
mail: arthur.debacq@amerique.iut
telephoneNumber: +1234567790

dn: uid=valentin.hebert,ou=Utilisateurs,ou=Informatique,dc=amerique,dc=iut
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: valentin.hebert
cn: Valentin Hebert
sn: Hebert
givenName: Valentin
displayName: Valentin Hebert
uidNumber: 1003
gidNumber: 2001
homeDirectory: /home/Informatique/valentin.hebert
loginShell: /bin/bash
userPassword: valentin
shadowLastChange: 19000
gecos: Valentin Hebert
mail: valentin.hebert@amerique.iut
telephoneNumber: +1234557890

dn: uid=younes.bensyed,ou=Utilisateurs,ou=Informatique,dc=amerique,dc=iut
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: younes.bensyed
cn: Younes Bensyed
sn: Bensyed
givenName: Younes
displayName: Younes Bensyed
uidNumber: 1004
gidNumber: 2001
homeDirectory: /home/Informatique/younes.bensyed
loginShell: /bin/bash
userPassword: younes
shadowLastChange: 19000
gecos: Younes Bensyed
mail: younes.bensyed@amerique.iut
telephoneNumber: +1224567890
```

Ajoutez nos utilisateurs avec :

```bash
sudo ldapadd -x -D "cn=admin,dc=amerique,dc=iut" -W -f create_default_users.ldif
```

Afin de simplifier la création d'utilisateur, nous avons créé un script ([create_user.sh](../../bin/service_info/ldap/create_user.sh)) lançable depuis le serveur LDAP pour des questions de gestion. Dans ce script, il est demandé :  
- Le nom complet de l'utilisateur  
- L'UID de l'utilisateur  
- Le mot de passe de l'utilisateur  
- Le groupe de l'utilisateur (admin, info, prod)  

Le script, comme tous les autres, peut être lancé avec les paramètres `-h` ou `--help` pour avoir plus d'informations sur son utilisation.

Ensuite l'utilisateur est crée et intégré au groupe qu'il a choisi. On peut aussi noter que la variable `homeDirectory` dans le fichier **.ldif** sert à indiquer le répertoire personnel de l'utilisateur, donc dans notre cas à l'intérieur des répertoires NFS. 

#### Suppresion d'un utilisateur de la base LDAP

De manière similaire à la création d'utilisateur, pour des raisons de facilité de gestion, nous avons développé un script de suppression d'utilisateur ([destroy_user.sh](../../bin/service_info/ldap/destroy_user.sh)). Ce script demande :  
- L'UID de l'utilisateur à supprimer  

Le script vérifie l'existence de l'utilisateur dans l'annuaire LDAP. Une fois trouvé, il retire l'utilisateur des groupes spécifiés (admin, info, prod), puis supprime son entrée de l'annuaire. Une confirmation est demandée avant la suppression définitive. Comme pour les autres scripts, l'option `-h` ou `--help` permet d'afficher des informations détaillées sur son utilisation.

#### Gestion des groupes

Pour ajouter un utilisateur à un groupe existant, nous modifions le groupe à l'aide d'un fichier `.ldif`. Par exemple, pour inclure un utilisateur *JeanDupont* dans le groupe *Employes_Administratif*, nous créons un fichier avec le contenu suivant :

```ldif
dn: cn=employeradministratif,ou=Administratif,dc=amerique,dc=iut
changetype: modify
add: memberUid
memberUid: jean.dupont
```

Ensuite, nous appliquons cette modification avec la commande suivante :

```bash
sudo ldapmodify -D "cn=admin,dc=amerique,dc=iut" -f chemin/vers/modification_groupe.ldif
```

---

#### Sauvegarde et restauration de la base LDAP

Pour effectuer une sauvegarde de la base LDAP, nous utilisons la commande suivante :

```bash
sudo slapcat -n 2 > sauvegarde_ldap.ldif
```

Cela exporte les données dans un fichier nommé `sauvegarde_ldap.ldif`.

Pour restaurer une sauvegarde, nous suivons les étapes ci-dessous :

Arrêter le service `slapd` :  
```bash
sudo systemctl stop slapd
```

Supprimer les anciennes données :  
```bash
sudo rm -rf /var/lib/ldap/*
```

Restaurer les données à partir du fichier de sauvegarde :  
```bash
sudo slapadd -n 2 -l sauvegarde_ldap.ldif
```

Redémarrer le service `slapd` :  
```bash
sudo systemctl start slapd
```

---

## Vérification et Recherche d'entités

### Vérification du statut du service OpenLDAP

Pour nous assurer du bon fonctionnement du service OpenLDAP, nous exécutons la commande suivante sur la machine virtuelle :

```bash
sudo systemctl status slapd
```

Le service doit apparaître comme **actif (running)**. Si ce n'est pas le cas, nous pouvons consulter les journaux pour identifier et résoudre les éventuels problèmes en utilisant la commande suivante :

```bash
sudo journalctl -xeu slapd
```

Quelques commandes utiles pour vérifier le bon fonctionnement du service LDAP :

```bash
# Lister toutes les entrées de la base LDAP
sudo ldapsearch -x -H ldapi:/// -b "dc=amerique,dc=iut"

# Rechercher une unité organisationnelle
sudo ldapsearch -x -H ldapi:/// -b "dc=amerique,dc=iut" "(objectClass=organizationalUnit)"

# Rechercher un utilisateur par son UID
sudo ldapsearch -x -H ldapi:/// -b "dc=amerique,dc=iut" "(uid=jean.dupont)"

sudo ldapsearch -x -H ldap://192.168.65.3 -b "dc=amerique,dc=iut" "(uid=jean.dupont)"
sudo ldapsearch -x -H ldap://10.64.0.1:389 -b "dc=amerique,dc=iut" "(uid=jean.dupont)"


```

## Retour au sommaire

- [Retourner au sommaire](../../README.md#documentations---liens-rapide)