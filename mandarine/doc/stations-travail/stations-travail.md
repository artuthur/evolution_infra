# Documentation pour la création des postes de travail 


## Contexte et objectifs

Le fichier Vagrant est conçu pour configurer un environnement virtuel simulant deux stations de travail dans un réseau privé administratif. Chaque station doit disposer au minimum des outils suivants installés et configurés de manière cohérente :

    - Navigateur web
    - Outil de gestion des emails

Le fichier utilise Vagrant et VirtualBox pour déployer les machines virtuelles (VM) nécessaires.

## Structure et configuration détaillée

### Configuration des routes réseau

Le script ajoute des routes réseau spécifiques demandé car les 2 stations de travail doivent etre déployés dans le réseaux administratif. 

Ces routes sont définies via la variable $hosts :

```bash
    ip r add 10.0.0.0/8 via 192.168.58.1 dev eth1
    ip r add 192.168.56.0/22 via 192.168.58.1 dev eth1
```
Ces commandes permettent :

- D’ajouter des routes pour les sous-réseaux spécifiques (10.0.0.0/8 et 192.168.56.0/22) en passant par la passerelle 192.168.58.1 sur l’interface réseau secondaire eth1.

    - Cela permet au 2 machines de pouvoir communiquer avec le tout le réseau privé.

Les modifications sont aussi ajouter dans le fichier /etc/network/interfaces pour persister après un redémarrage.

```bash
   sudo sed -i '/post-up ip route del default dev \\$IFACE || true/a \\    up ip route add 10.0.0.0/8 via 192.168.58.1 dev eth1\\n    up ip route add 192.168.56.0/22 via 192.168.58.1 dev eth1' /etc/network/interfaces
```

### Mise à jour du système et installation des outils

Le fichier assure que chaque machine virtuelle dispose des derniers correctifs de sécurité et des logiciels nécessaires :
    
```bash
    apt-get update -y && apt-get upgrade -y
```

### Installation des outils :
        
Interface graphique XFCE : Permet de fournit un environnment graphique afin de pouvoir se connecter au poste via interface graphique.

```bash
    apt-get install -y xfce4 xfce4-goodies
```

Firefox ESR : Navigateur web afin de pouvoir lancer un navigateur web dans nos postes de travail.

```bash
    apt-get install -y firefox-esr firefox-esr-l10n-fr
```

L’accès à la boîte mail se fait via le web grâce à notre outil Rainloop. Vous pourrez y accéder directement depuis un navigateur en vous rendant à l’adresse suivante :

```
http://mail.mandarine.iut
```
- Identifiants nécessaires : Entrez votre adresse mail et mot de passe pour accéder à vos courriels.

### Configuration du clavier

Le clavier est configuré en disposition française :

```bash
    sudo setxkbmap fr
    sudo sed -i 's/XKBLAYOUT="\w*"/XKBLAYOUT="fr"/g' /etc/default/keyboard
```
Cette modification rend la configuration du clavier persistante.

### Scripts clients

Deux scripts externes sont appelés à partir de la machine hôte (fichiers présents dans le dossier partagé /vagrant) :

- provision-client.sh : Ce script permet aux 2 machines de devenir des clients ldap pour le serveur se trouvant dans le 
    réseaux informatique.

- client-nfs.sh : Ce script permet aux 2 machines de devenir clients nfs et donc de pouvoir lier les repertoires home au serveur nfs.

**Toute cette configuration permet donc l'automatisation de l'installation des 2 postes de travail.**

Ces postes repondes donc aux exigences suivantes : 

- outils necessaires a l'utilisation du poste de travail.
- un navigateur web.
- un outils de gestion des emails.
- 2 machines présente sur le réseau administratif. 
