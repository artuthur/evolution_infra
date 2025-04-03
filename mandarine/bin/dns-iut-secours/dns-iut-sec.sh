# !/bin/bash

# Fonction pour afficher l'aide
function afficher_aide() {
cat << EOF
usage: ./dns-iut-sec.sh [OPTIONS]

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
    echo "Pour plus d'aide veuillez taper la commande suivante : ./dns-iut-sec.sh -h ou ./dns-iut-sec.sh --help"
    exit 1
fi

apt-get update -y

# Installation de bind9
apt install bind9 bind9utils bind9-doc -y

# Mise en place d'une route vers le réseau 10.0.0.0/8
ip r add 10.0.0.0/8 via 10.192.0.254 dev eth1
ip r add 192.168.56.0/22 via 10.192.0.254 dev eth1

# Configuration du serveur DNS dans resolv.conf
cat << TUTU > /etc/resolv.conf
nameserver 10.192.0.5
nameserver 10.192.0.50
TUTU

cat << EOF >> /etc/hosts
# Partie publique
10.192.0.2 dns-mandarine.iut
10.192.0.3 mail.mandarine.iut
10.192.0.3 web.mandarine.iut
10.192.0.5 dns-iut
10.192.0.6 dns-mandarine.iut-sec
10.192.0.50 dns-iut-sec

#Partie privé
192.168.57.3 dhcp
192.168.57.4 ldap
192.168.57.5 nfs
EOF

# Début de la configuration du DNS mandarine
# Création des zones dans le fichier named.conf.local 
cat << TOTO > /etc/bind/named.conf.local
zone "iut" {
    type slave;                           // Indique qu'il s'agit d'une zone secondaire
    masters { 10.192.0.5; };              // Spécifie l'adresse IP du serveur maître
    file "/var/cache/bind/db.iut";        // Fichier local de sauvegarde pour la zone
};

zone "5.0.192.10.in-addr.arpa" {
    type slave;
    masters { 10.192.0.5; };              // Maître pour la zone inverse
    file "/var/cache/bind/db.10.0-ptr";   // Fichier de sauvegarde pour la zone inverse
};
TOTO

cat << DNS > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";        // Répertoire de cache utilisé par Bind9

    dnssec-validation auto;            // Active la validation DNSSEC automatique

    recursion yes;                     // Autorise la récursivité pour résoudre les noms externes

    allow-recursion { any; };          // Permet la récursivité pour toutes les adresses (peut être restreint)

    listen-on-v6 { any; };             // Écoute sur toutes les interfaces IPv6
    listen-on { any; };                // Écoute sur toutes les interfaces IPv4
};
DNS

systemctl restart named.service
