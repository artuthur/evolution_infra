# !/bin/bash

# Fonction pour afficher l'aide
function afficher_aide() {
cat << EOF
usage: ./mail-mand.sh [OPTIONS]

Ce script configure un serveur DNS de secours pour le domaine "iut" sur le réseau 
et effectue toutes les configurations nécessaires pour assurer la gestion du DNS, 
la résolution des noms et la gestion des enregistrements associés en mode esclave.

OPTIONS :
    -h, --help   Affiche ce message d'aide

Ce script effectue les tâches suivantes :
    - Mise à jour du système et installation de `bind9` (serveur DNS).
    - Configuration des routes pour le réseau privé et public.
    - Modification du fichier `/etc/hosts` pour inclure les hôtes.
    - Création des fichiers de zone pour le domaine "iut" et sa reverse DNS, en mode esclave.
    - Ajout du serveur DNS maître pour la synchronisation des zones.
    - Configuration de `named.conf.local`, `db.iut`, et `db.10-ptr` pour définir 
      les zones et les enregistrements nécessaires en mode esclave.
    - Démarrage du service DNS (`named`) pour activer la configuration.

Le domaine configuré est "iut", avec des serveurs DNS maîtres et secondaires 
répartis géographiquement (en Afrique, Amérique, Asie, Mandarine) pour garantir 
la redondance et la résilience de la résolution des noms de domaine et de la délégation 
de sous-domaines.
EOF
}

# Gestion des options
if [[ "$#" -eq 1 && "$1" == "-h" ]] || [[ "$#" -eq 1 && "$1" == "--help" ]]; then
    afficher_aide
    exit 0
elif [[ "$#" -gt 0 ]]; then
    echo "Erreur: Argument non reconnu : $1\n"
    echo "Pour plus d'aide veuillez taper la commande suivante : ./mail-mand.sh -h ou ./mail-mand.sh --help"
    exit 1
fi

# Mise en place d'une route vers le réseau 10.0.0.0/8
ip r add 10.0.0.0/8 dev eth1

# On modifie l'ip du nameserver
sed -i 's/nameserver 10.0.2.3/nameserver 10.192.0.2/' /etc/resolv.conf

apt-get update && apt-get upgrade -y
apt-get install apache2 mariadb-server php8.2 -y
apt-get install php8.2-mysql php8.2-mbstring php8.2-imap php8.2-xml php8.2-curl -y
service apache2 restart
apt-get install tree mailutils -y
apt-get install postfix postfix-mysql -y
apt-get install dovecot-mysql dovecot-pop3d dovecot-imapd dovecot-managesieved -y
apt-get install libapache2-mod-php php -y

sudo mkdir -p /var/www/web
echo "<h1>Bienvenue chez Mandarine</h1>" | sudo tee /var/www/web/index.html

cat << EOF > /etc/apache2/sites-available/mail.mandarine.iut.conf
<VirtualHost *:80>
    ServerName mail.mandarine.iut
    DocumentRoot /var/www/html/rainloop/

    <Directory /var/www/html/rainloop/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/mail.mandarine.iut-error.log
    CustomLog ${APACHE_LOG_DIR}/mail.mandarine.iut-access.log combined
</VirtualHost>
EOF

cat << TTT > /etc/apache2/sites-available/web.mandarine.iut.conf
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
TTT

sudo chown -R www-data:www-data /var/www/html/rainloop
sudo chmod -R 755 /var/www/html/rainloop

sudo a2ensite web.mandarine.iut.conf
sudo a2ensite mail.mandarine.iut.conf
sudo a2enmod rewrite
sudo systemctl reload apache2

