# Documentation pour le serveur web

## Objectif
Configurer un serveur web Apache2 avec une page d'accueil personnalisée et un hôte virtuel dédié sur une machine virtuelle Debian. Le serveur est intégré dans l’infrastructure réseau et partage la machine virtuelle avec le serveur mail.

## Contexte
Le serveur web est hébergé sur la machine virtuelle `srv-mail`, qui assure également le rôle de serveur mail.  
L'application web **Rainloop** est utilisée pour la gestion des boîtes mail. Un hôte virtuel est configuré pour l’accès HTTP, permettant une séparation claire entre les services.

## Configuration réseau et machine virtuelle

### Machine virtuelle
- **Nom de la machine** : `srv-mail`
- **Adresse IP** : `10.192.0.3` (réseau public configuré)
- **Passerelle** : `Douglas01`, qui sert de bridge entre l’ordinateur physique et la machine virtuelle.

### Vagrantfile
Le fichier `Vagrantfile` utilisé pour configurer la machine virtuelle est disponible ici :  
[srv-mail](../../bin/srv-mail/Vagrantfile).

Une fois que vous avez terminé l'[installation du serveur mail](../mail/installation-serveur-mail.md), exécutez le script d'installation pour le serveur web en tant qu'utilisateur root :

```bash
cd /vagrant/srv-mail
./web-mand.sh
```

## Configuration réseau

### Ajout des routes
Ajoutez les routes nécessaires pour permettre la communication avec d'autres machines et l'accès à Internet :

```bash
ip r add 10.0.0.0/8 via 10.192.0.254 dev eth1
ip r add 192.168.56.0/22 via 10.192.0.254 dev eth1
```

- **10.0.0.0/8** : Plage pour l'ensemble du réseau public.
- **192.168.56.0/22** : Accès aux sous-réseaux privés.
- **10.192.0.254** : Adresse IP de la passerelle.

### Configuration DNS
Pour utiliser le DNS interne, mettez à jour le fichier `/etc/resolv.conf` avec les adresses des serveurs DNS locaux :

```bash
cat << EOF > /etc/resolv.conf
nameserver 10.192.0.2
nameserver 10.192.0.6
EOF
```

## Installation et configuration d'Apache2

### Installation d'Apache2
Installez Apache2 avec la commande suivante :

```bash
apt install apache2 -y
```

### Création de la page d'accueil
Créez une page HTML pour tester le serveur web.

1. Créez le répertoire dédié au site web :

   ```bash
   mkdir -p /var/www/web
   ```

2. Créez la page d'accueil `index.html` avec ce contenu :

   ```bash
   cat << EOF > /var/www/web/index.html
   <h1>Bienvenue chez Mandarine</h1>
   EOF
   ```

## Configuration de l'hôte virtuel

### Création du fichier de configuration
Ajoutez un fichier de configuration dans `/etc/apache2/sites-available` pour définir l'hôte virtuel.

1. Créez le fichier `web.mandarine.iut.conf` :

   ```bash
   cat << EOF > /etc/apache2/sites-available/web.mandarine.iut.conf
   <VirtualHost *:80>
       ServerName web.mandarine.iut
       DocumentRoot /var/www/web

       <Directory /var/www/web>
           Options Indexes FollowSymLinks
           AllowOverride All
           Require all granted
       </Directory>

       ErrorLog ${APACHE_LOG_DIR}/web_error.log
       CustomLog ${APACHE_LOG_DIR}/web_access.log combined
   </VirtualHost>
   EOF
   ```

2. Activez le site avec cette commande :

   ```bash
   a2ensite web.mandarine.iut.conf
   ```

3. Si nécessaire, désactivez le site par défaut (facultatif) :

   ```bash
   a2dissite 000-default.conf
   ```

### Redémarrage du serveur Apache
Rechargez la configuration pour appliquer les modifications :

```bash
sudo systemctl reload apache2
```

Vérifiez l'état du service Apache :

```bash
systemctl status apache2
```

## Vérification

1. **Accéder au site web** :  
   Depuis un navigateur, entrez l’adresse suivante :  
   [http://web.mandarine.iut](http://web.mandarine.iut).  
   Vous devriez voir une page affichant :  
   *"Bienvenue chez Mandarine"*.

2. **Tester la configuration** :  
   - Utilisez la commande `curl` pour vérifier localement :  

     ```bash
     curl http://web.mandarine.iut
     ```  
   - Vérifiez les logs Apache pour confirmer qu'il n'y a pas d'erreurs :

     ```bash
     tail -f /var/log/apache2/web_error.log
     ```

Si tu as d'autres ajustements ou ajouts à faire, n'hésite pas à me le dire ! 😊