---
title: Mise en place des stations de travail
---

# Mise en place des stations de travail

## Objectif

Mettre en place un environnement de travail privé avec **deux stations de travail** disposant d'un **navigateur web** (Mozilla Firefox) et d'un **outil de gestion de messagerie** (Mozilla Thunderbird) dans un environnement graphique. Ces machines doivent être accessibles graphiquement afin de fournir un accès complet aux utilisateurs pour les tâches bureautiques.

## Pourquoi utiliser Vagrant et VirtualBox ?

### Choix des outils

1. **VirtualBox** : C'est un hyperviseur open-source permettant de créer et gérer des machines virtuelles (VM) localement. Il est largement compatible, performant pour des stations de travail, et offre des options d'interface graphique qui sont essentielles ici.
2. **Vagrant** : Cet outil permet d'automatiser la configuration des VM, de standardiser les environnements et d'améliorer la productivité grâce à un seul fichier de configuration (`Vagrantfile`). Avec Vagrant, le déploiement de plusieurs VMs identiques est rapide et facile à gérer.

### Avantages de cette solution

- **Automatisation** : La configuration des stations de travail (système d'exploitation, applications, ressources matérielles) est définie dans le fichier `Vagrantfile`, ce qui rend l'installation réplicable et rapide.
- **Interface graphique** : L'option `vb.gui = true` permet d'ouvrir chaque VM avec une interface graphique, offrant une expérience utilisateur complète.
- **Modularité** : Avec Vagrant, il est facile d'ajouter ou de modifier des machines en éditant simplement le `Vagrantfile`.

## Prérequis

- **VirtualBox** installé sur le système hôte. Téléchargez-le depuis [https://www.virtualbox.org/](https://www.virtualbox.org/).
- **Vagrant** installé sur le système hôte. Téléchargez-le depuis [https://www.vagrantup.com/](https://www.vagrantup.com/).

## Configuration des Stations de Travail

### 1. Création du Fichier Vagrantfile

Le fichier `Vagrantfile` contient les configurations nécessaires pour déployer les deux machines virtuelles avec les caractéristiques demandées.

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  
  # Ajout des routes
  #config.vm.provision "shell", path: "../../conf_reseau/conf_routes_vagrant.sh"
  # Provisionnement : installation des logiciels requis et autres
  config.vm.provision "shell", path: "../../conf_workstation/provision_workstation.sh"
  # Provisionnement : Configuration Cliente NFS
  #config.vm.provision "shell", path: "../../service_info/nfs/client-conf-nfs-ldap.sh"

  # Le réseau privé du service admin doit héberger a minima deux stations de travail (2 config.vm.define) avec naviguateur web (mozilla) et outil de gestion de mail (thunderbird)

  config.vm.define "stationtravail1" do |station1|
      station1.vm.network "public_network", type: "dhcp", mac: "080027123462", bridge: "enp3s0"
      station1.vm.box = "debian/bookworm64"
      station1.vm.hostname = "stationtravail1"

      # Configuration VirtualBox pour chaque VM
      station1.vm.provider "virtualbox" do |vb|
        vb.gui = true                   # Active l'affichage graphique
        vb.memory = "2048"              
        vb.cpus = 2                     
      end
  end

  config.vm.define "stationtravail2" do |station2|
    station2.vm.network "public_network", type: "dhcp", mac: "080027123463", bridge: "enp3s0" 
    station2.vm.box = "debian/bookworm64"
    station2.vm.hostname = "stationtravail2"

    # Configuration VirtualBox pour chaque VM
    station2.vm.provider "virtualbox" do |vb|
      vb.gui = true                   # Active l'affichage graphique
      vb.memory = "2048"              
      vb.cpus = 2                     
    end
  end
end

```

### Explications du Fichier Vagrantfile

1. **Définition de la box Debian Bookworm** : `station.vm.box = "debian/bookworm64"` utilise une version officielle et à jour de Debian (Bookworm).
2. **Configuration graphique** : L’option `vb.gui = true` active l’affichage graphique pour chaque machine, ouvrant ainsi une fenêtre pour l'interface graphique de la VM.
3. **Ressources matérielles** : Chaque machine se voit attribuer 2 Go de RAM et 2 CPU, offrant ainsi des performances adéquates pour la navigation web et la gestion d'emails.
4. **Installation des applications** : Lors du provisionnement, Vagrant exécute une commande shell pour installer Firefox et Thunderbird (`apt-get install -y firefox-esr thunderbird`).
5. **Configuration du réseau** : Les routes vers l'exterieur et les adresses MAC (afin d'éviter les bugs avec DHCP) sont configurées lors du provisionnement et l'adresse IP est-elle délivré par le DHCP.
6. **Montage du NFS & Intégration LDAP** : La configuration cliente du NFS & LDAP est réalisé lors du provisionnement avec l'execution du script `provision_worksation.sh`.

### 2. Lancer les Stations de Travail

Dans le répertoire contenant le `Vagrantfile`, exécutez les commandes suivantes :

```bash
vagrant up
```

- Cette commande va télécharger la box Debian Bookworm (si elle n’est pas déjà présente), créer et configurer les deux stations de travail, puis les démarrer avec une interface graphique.

### 3. Accéder aux Machines Virtuelles

À la fin du processus de `vagrant up`, deux fenêtres VirtualBox s’ouvriront, chacune contenant une des stations de travail configurées avec Debian et les applications installées.

### 4. Gestion des Stations de Travail

- **Arrêter les VMs** : Pour éteindre les machines, exécutez :
  ```bash
  vagrant halt
  ```
- **Redémarrer les VMs** : Pour redémarrer les machines sans les reconfigurer, utilisez :
  ```bash
  vagrant up
  ```
- **Détruire les VMs** : Pour supprimer les machines et libérer de l'espace disque :
  ```bash
  vagrant destroy
  ```

## Notes

- **Mises à jour** : Si vous souhaitez mettre à jour les packages ou configurer d'autres logiciels, éditez la section `station.vm.provision` dans le `Vagrantfile` et relancez les machines.
- **DNS et passerelles** : Les machines sont configurés via un provisonnement shell afin d'obtenir une passerelle via `ip route` ainsi que pour qu'elles utilisent le DNS du service Informatique (`nameserver 10.64.0.2`) via le fichier `resolv.conf`



### Intégration avec LDAP

#### Installation des paquets

Nous commençons par installer les paquets nécessaires pour l'intégration LDAP en exécutant les commandes suivantes :

```bash
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt install -y libnss-ldapd libpam-ldapd ldap-utils
```

- `libnss-ldapd`, `libpam-ldapd`, et `ldap-utils` sont les composants indispensables pour permettre l'authentification des utilisateurs via LDAP.

#### Configuration de `nslcd.conf` pour l'intégration LDAP

Ensuite, nous configurons le fichier `/etc/nslcd.conf` pour intégrer notre serveur LDAP en précisant l'URI du serveur et la base LDAP :

```bash
cat <<EOF | sudo tee /etc/nslcd.conf > /dev/null
uid nslcd
gid nslcd
uri ldap://192.168.65.3
base dc=amerique,dc=iut
EOF
```

Dans ce fichier, nous définissons :  
- L'URI du serveur LDAP : `ldap://192.168.65.3`.  
- La base LDAP : `dc=amerique,dc=iut`.  

Ces paramètres permettent au système d'interroger le serveur LDAP pour récupérer les informations nécessaires à l'authentification des utilisateurs.

#### Modification de `nsswitch.conf` pour activer l'utilisation de LDAP

Nous modifions ensuite le fichier `/etc/nsswitch.conf` pour indiquer que l'authentification doit se baser à la fois sur les fichiers locaux et sur LDAP :

```bash
sudo sed -i 's/^passwd:.*/passwd:         files ldap/' /etc/nsswitch.conf
sudo sed -i 's/^group:.*/group:          files ldap/' /etc/nsswitch.conf
sudo sed -i 's/^shadow:.*/shadow:         files ldap/' /etc/nsswitch.conf
sudo sed -i 's/^gshadow:.*/gshadow:        files ldap/' /etc/nsswitch.conf
```

Grâce à ces modifications, les informations relatives aux utilisateurs, aux groupes, aux mots de passe et aux fichiers shadow sont consultées à la fois localement et via LDAP.

---

#### Redémarrage des services nécessaires

Enfin, nous redémarrons les services `nscd` et `nslcd` afin d'appliquer les nouvelles configurations :

```bash
sudo systemctl restart nscd nslcd
```

Ce redémarrage garantit que les modifications liées à l'intégration LDAP sont prises en compte.

### Création des répertoires utilisateurs LDAP

Nous avons crée un script permettant de créer automatiquement les répertoires utilisateurs ([user-home.sh](../../bin/service_info/nfs/user-home.sh)).

Un répertoire est créé pour chaque utilisateur du groupe, avec des permissions strictes :
   - Propriétaire : utilisateur et groupe associés.
   - Permissions : `700` pour garantir la confidentialité.

### Automatisation de l'éxecution avec cron

Pour automatiser l'exécution de ce script, nous utilisons **cron**. Cela permet de garantir que les répertoires des nouveaux utilisateurs LDAP soient créés sans intervention manuelle. Il faut au préalable tester si le script est éxecutable sinon il faut utiliser la commande `chmod`
  
Ajoutez une entrée dans le cron pour exécuter le script à intervalles réguliers. Par exemple, pour une exécution quotidienne à 3h du matin :
```bash
sudo crontab -e
```

Ajoutez la ligne suivante :
```bash
0 3 * * * /chemin/vers/le/script/user-home.sh >> /var/log/user-home.log 2>&1
```

Vérifiez que l’entrée a bien été ajoutée en listant les tâches cron :

```bash
sudo crontab -l
```

---

### Configuration des Clients NFS et intégration LDAP

La configuration du client revient à faire la configuration nfs et l'intégration LDAP effectué ci-dessus, nous allons quand même répeter les étapes de configuration mais un script [client-conf-nfs-ldap](../../bin/service_info/nfs/client-conf-nfs-ldap.sh) a été réalisé dans ce but.

#### Installation des paquets nécessaires

Nous commençons par installer les paquets requis sur le client en exécutant les commandes suivantes :

```bash
sudo apt update
sudo apt-get install nfs-common tree -qy
sudo DEBIAN_FRONTEND=noninteractive apt install -y libnss-ldapd libpam-ldapd ldap-utils
```

Ces paquets permettent de configurer le montage NFS et d'intégrer le client avec un serveur LDAP.

---

#### Configuration de `nslcd.conf`

Nous configurons le fichier `/etc/nslcd.conf` pour indiquer l’URI du serveur LDAP et la base LDAP utilisée :

```bash
cat <<EOF | sudo tee /etc/nslcd.conf > /dev/null
uid nslcd
gid nslcd
uri ldap://192.168.65.3
base dc=amerique,dc=iut
EOF
```

---

#### Modification de `nsswitch.conf` pour intégrer LDAP

Nous modifions ensuite le fichier `/etc/nsswitch.conf` pour que les informations d’authentification soient récupérées à la fois depuis les fichiers locaux et via LDAP :

```bash
sudo sed -i 's/^passwd:.*/passwd:         files ldap/' /etc/nsswitch.conf
sudo sed -i 's/^group:.*/group:          files ldap/' /etc/nsswitch.conf
sudo sed -i 's/^shadow:.*/shadow:         files ldap/' /etc/nsswitch.conf
sudo sed -i 's/^gshadow:.*/gshadow:        files ldap/' /etc/nsswitch.conf
```

---

#### Redémarrage des services nécessaires

Nous appliquons les modifications en redémarrant les services :

```bash
sudo systemctl restart nscd nslcd
```

---

## Conclusion

Cette solution permet de déployer et de configurer automatiquement des stations de travail graphiques sur un réseau privé. Vagrant et VirtualBox simplifient le processus de gestion et de maintenance, et cette méthode peut être facilement adaptée pour répondre à des besoins similaires dans d’autres contextes bureautiques.

## Retour au sommaire

- [Retourner au sommaire](../../README.md#documentations---liens-rapide)
