#!/bin/bash

# Fonction pour afficher l'aide
function afficher_aide() {
cat << EOF
usage: ./web-mand.sh [OPTIONS]

Ce script configure un serveur web pour le domaine "mandarine.iut", en effectuant 
les configurations nécessaires pour l'intégration avec le serveur DNS en mode esclave, 
ainsi que la gestion des fichiers de configuration pour Apache.

OPTIONS :
    -h, --help   Affiche ce message d'aide

Ce script effectue les tâches suivantes :
    - Mise à jour du système et installation de `bind9` (serveur DNS).
    - Configuration des routes pour le réseau privé et public.
    - Modification du fichier `/etc/hosts` pour inclure les hôtes.
    - Création des fichiers de zone pour le domaine "mandarine.iut" et sa reverse DNS, en mode esclave.
    - Ajout du serveur DNS maître pour la synchronisation des zones.
    - Configuration de `named.conf.local`, `db.mandarine.iut`, et `db.10-ptr` pour définir 
      les zones et les enregistrements nécessaires en mode esclave.
    - Démarrage du service DNS (`named`) pour activer la configuration.
    - Installation d'un serveur web Apache.
    - Création d'une page web d'accueil pour le domaine "mandarine.iut".
    - Configuration d'Apache pour servir le site web et l'intégration de Rainloop pour la gestion des mails.

Le domaine configuré est "mandarine.iut", avec des serveurs DNS maîtres et secondaires 
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
    echo "Pour plus d'aide veuillez taper la commande suivante : ./web-mand.sh -h ou ./web-mand.sh --help"
    exit 1
fi

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