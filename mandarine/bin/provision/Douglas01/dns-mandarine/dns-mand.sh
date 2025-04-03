#!/bin/bash

# Fonction pour afficher l'aide
function afficher_aide() {
cat << EOF
usage: ./dns-mand.sh [OPTIONS]

Ce script déploie la configuration DNS pour le domaine "mandarine.iut" et configure 
les zones DNS nécessaires pour la gestion du réseau. Ce script est utilisé pour 
la configuration de serveurs DNS principaux et secondaires dans le cadre d'un 
réseau distribué, avec des serveurs DNS esclaves et maîtres, ainsi que la configuration 
des services associés tels que le serveur web et le serveur mail.

OPTIONS :
    -h, --help   Affiche ce message d'aide

Ce script effectue les tâches suivantes :
    - Mise à jour du système et installation de `bind9` (serveur DNS).
    - Configuration des routes vers les réseaux privé et public.
    - Modification du fichier `/etc/hosts` pour inclure les hôtes 
    de la partie publique et privée.
    - Configuration des zones DNS pour le domaine "mandarine.iut" 
    et le sous-domaine inverse "10.192.0.0/24".
    - Configuration du serveur DNS maître pour le sous-domaine `mandarine.iut` 
    et la zone inverse.
    - Mise en place de la résolution DNS inverse pour l'adressage IP.
    - Ajout d'enregistrements A et PTR pour les services web, mail et DNS.
    - Ajout d'enregistrement MX pour le serveur de messagerie.
    - Configuration des options globales dans `named.conf.options` 
    pour autoriser la mise en cache et la résolution des noms externes.
    - Démarrage du service DNS (`named`) pour activer la configuration.

Le domaine configuré est "mandarine.iut", avec des serveurs DNS maîtres et secondaires 
répartis géographiquement pour garantir une haute disponibilité des services de résolution DNS 
et la redondance du réseau.

EOF
}


# Gestion des options
if [[ "$#" -eq 1 && "$1" == "-h" ]] || [[ "$#" -eq 1 && "$1" == "--help" ]]; then
    afficher_aide
    exit 0
elif [[ "$#" -gt 0 ]]; then
    echo "Erreur: Argument non reconnu : $1\n"
    echo "Pour plus d'aide veuillez taper la commande suivante : ./dns-mand.sh -h ou ./dns-mand.sh --help"
    exit 1
fi

apt-get update -y

# Installation de bind9
apt install bind9 bind9utils bind9-doc -y

# Mise en place d'une route vers le réseau 10.0.0.0/8
ip r add 10.0.0.0/8 via 10.192.0.254 dev eth1
ip r add 192.168.56.0/22 via 10.192.0.254 dev eth1

# Configuration du serveur DNS dans resolv.conf (méthode manuelle, à vérifier selon votre système)
cat << CACA > /etc/resolv.conf
nameserver 10.192.0.2
nameserver 10.192.0.6
CACA

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
# Configuration en tant qu'esclave pour le domaine iut
zone "iut" {
    type slave;
    file "/var/cache/bind/db.iut";
    masters { 10.192.0.5; };  # Serveur maître .iut
};

# Zone inverse pour 10.192.0.0/24 (sous-réseau de mandarine)
zone "10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.10-ptr";
    masters { 10.192.0.5; };
};

# Zone maîtresse pour le sous-domaine mandarine.iut
zone "mandarine.iut" {
    type master;
    file "/etc/bind/db.mandarine.iut";  # Fichier contenant les enregistrements DNS locaux
};

# Zone maîtresse inverse pour le sous-domaine mandarine.iut
zone "0.192.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.0.192.10-ptr";
};
TOTO

# Création du fichier de zone db.mandarine.iut
cat << EOF > /etc/bind/db.mandarine.iut
;
; Zone file for mandarine.iut
;
\$TTL    604800
@       IN      SOA     mandarine.iut. admin.mandarine.iut. (
                              2023101501   ; Numéro de série (YYYYMMDDNN)
                              604800       ; Rafraîchissement (7 jours)
                              86400        ; Réessai (1 jour)
                              2419200      ; Expiration (4 semaines)
                              604800 )     ; Cache négatif TTL (1 semaine)

; Serveurs DNS pour le domaine mandarine.iut
@       IN      NS      ns1.mandarine.iut.
@       IN      NS      ns2.mandarine.iut.

; Enregistrements A pour les services de mandarine.iut
ns1.mandarine.iut.      IN      A       10.192.0.2              ; Serveur DNS
ns2.mandarine.iut.      IN      A       10.192.0.6              ;
web.mandarine.iut.      IN      A       10.192.0.3              ; Serveur web (Apache)
mail.mandarine.iut.     IN      A       10.192.0.3              ; Serveur mail
autoconfig.             IN      CNAME   mandarine.iut.          ;
mandarine.iut.          IN      TXT     "v=spf1 a mx -all"      ;

; Enregistrement MX pour la gestion des mails
@                       IN      MX      10 mail.mandarine.iut.
EOF

# Création du fichier de zone db.2.0.192.10-ptr
cat << TATA > /etc/bind/db.0.192.10-ptr
;
; BIND reverse data file for 10.192.0.0/24
;
\$TTL    604800
@       IN      SOA     mandarine.iut. admin.mandarine.iut. (
                              2023101203   ; Numéro de série (YYYYMMDDNN)
                              604800       ; Rafraîchissement (7 jours)
                              86400        ; Réessai (1 jour)
                              2419200      ; Expiration (4 semaines)
                              604800 )     ; Cache négatif TTL (1 semaine)

; Serveur DNS principal de la zone inverse
@       IN      NS      ns1.mandarine.iut.

; Résolution inverse (PTR) pour les adresses IP
2       IN      PTR     ns1.mandarine.iut.    ; Résolution inverse pour 10.192.0.2
3       IN      PTR     mail.mandarine.iut.   ; Résolution inverse pour 10.192.0.3
3       IN      PTR     web.mandarine.iut.    ; Alias pour 10.192.0.3 (serveur Web/Mail)
6       IN      PTR     ns2.mandarine.iut.    ; Résolution inverse pour 10.192.0.6

TATA

# Configuration des options globales dans named.conf.options
cat << DNS > /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";
        
        dnssec-validation auto;

        listen-on-v6 { any; };

        forwarders {
                10.192.0.5;  # Adresse du maître pour la résolution externe
                10.192.0.50;
        };

        recursion yes;

	allow-query-cache { 192.168.57.0/24; 130.130.0.0/16; 192.168.58.0/24; 10.0.0.0/8; };
	allow-query { 192.168.57.0/24; 130.130.0.0/16; 192.168.58.0/24; 10.0.0.0/8; };
};
DNS

systemctl restart named.service
