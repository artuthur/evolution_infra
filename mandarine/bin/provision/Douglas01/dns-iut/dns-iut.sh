# !/bin/bash

# Fonction pour afficher l'aide
function afficher_aide() {
cat << EOF
usage: ./dns-iut.sh [OPTIONS]

Ce script configure un serveur DNS pour le domaine "iut" sur le réseau 
et effectue toutes les configurations nécessaires pour assurer la gestion 
du DNS et des enregistrements associés. 
Le script inclut la configuration des zones, des enregistrements A et PTR, 
et des serveurs DNS secondaires.

OPTIONS :
    -h, --help   Affiche ce message d'aide

Ce script effectue les tâches suivantes :
    - Mise à jour du système et installation de `bind9` (serveur DNS).
    - Configuration des routes pour le réseau privé et public.
    - Modification du fichier `/etc/hosts` pour inclure les hôtes.
    - Création des fichiers de zone pour le domaine "iut" et sa reverse DNS.
    - Ajout des serveurs DNS secondaires pour la redondance et la résilience.
    - Configuration de `named.conf.local`, `db.iut`, et `db.10-ptr` pour définir 
      les zones et les enregistrements nécessaires.
    - Démarrage du service DNS (`named`) pour activer la configuration.

Le domaine configuré est "iut", avec des serveurs DNS répartis géographiquement 
(en Afrique, Amérique, Asie et Mandarine) pour assurer la gestion de la résolution de 
noms et la délégation de sous-domaines.

EOF
}

# Gestion des options
if [[ "$#" -eq 1 && "$1" == "-h" ]] || [[ "$#" -eq 1 && "$1" == "--help" ]]; then
    afficher_aide
    exit 0
elif [[ "$#" -gt 0 ]]; then
    echo "Erreur: Argument non reconnu : $1\n"
    echo "Pour plus d'aide veuillez taper la commande suivante : ./dns-iut.sh -h ou ./dns-iut.sh --help"
    exit 1
fi

# Ajout de bind9
apt install bind9 bind9utils bind9-doc -y

# Mise en place d'une route vers le réseau 10.0.0.0/8
ip r add 10.0.0.0/8 via 10.192.0.254 dev eth1
ip r add 192.168.56.0/22 via 10.192.0.254 dev eth1

# On modifie l'ip du nameserver
#sed -i 's/nameserver 10.0.2.3/nameserver 10.192.0.5/' /etc/resolv.conf
cat << CACA > /etc/resolv.conf
nameserver 10.192.0.5
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

# Début de la configuration du DNS iut
# Création des zones dans le fichier named.conf.local 
cat << EOF > /etc/bind/named.conf.local
zone "iut" {
    type master;
    file "/etc/bind/db.iut";
    allow-transfer { 10.0.0.2; 10.0.0.20; 10.64.0.2; 10.64.0.5; 10.128.0.2; 10.128.0.5; 10.192.0.2; 10.192.0.6; 10.192.0.50; };
    also-notify { 10.0.0.2; 10.0.0.20; 10.64.0.2; 10.64.0.5; 10.128.0.2; 10.128.0.5; 10.192.0.2; 10.192.0.6; 10.192.0.50; }; 
};

zone "10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10-ptr";  # Ce fichier contiendra toutes les informations PTR
    allow-transfer { 10.0.0.2; 10.0.0.20; 10.64.0.2; 10.64.0.5; 10.128.0.2; 10.128.0.5; 10.192.0.2; 10.192.0.6; 10.192.0.50; };
    also-notify { 10.0.0.2; 10.0.0.20; 10.64.0.2; 10.64.0.5; 10.128.0.2; 10.128.0.5; 10.192.0.2; 10.192.0.6; 10.192.0.50; };
};
EOF

# Création du fichier de zone db.iut
cat << TATA > /etc/bind/db.iut
;
; Zone file for iut
;
\$TTL    604800         ; Time to Live par défaut
@       IN      SOA     ns1.iut. admin.iut. (
                              2024112502    ; Numéro de série (YYYYMMDDNN)
                              604800       ; Rafraîchissement (7 jours)
                              86400        ; Réessai (1 jour)
                              2419200      ; Expiration (4 semaines)
                              604800 )     ; Cache négatif TTL (1 semaine)

; Serveurs DNS pour le domaine iut
@       IN      NS      ns1.iut.          ; Serveur DNS principal
@	    IN	    NS	    ns2.iut.
@       IN      NS      afrique.iut.      ; Serveur secondaire Afrique
@       IN      NS      amerique.iut.     ; Serveur secondaire Amérique
@       IN      NS      asie.iut.         ; Serveur secondaire Asie
@       IN      NS      mandarine.iut.    ; Serveur secondaire Mandarine

; Enregistrements A pour les serveurs DNS
ns1.iut.       IN      A      10.192.0.5          ; IP du serveur DNS maître
ns2.iut.       IN      A      10.192.0.50         ;
afrique        IN      A      10.0.0.2            ; IP du DNS secondaire Afrique
amerique       IN      A      10.64.0.2           ; IP du DNS secondaire Amérique
asie           IN      A      10.128.0.2          ; IP du DNS secondaire Asie
mandarine      IN      A      10.192.0.2          ; IP du DNS secondaire Mandarine

; Délégation pour les sous-domaines
afrique.iut.    IN  NS      ns1.afrique.iut.  ; Serveur DNS principal pour afrique.iut
afrique.iut.    IN  NS      ns2.afrique.iut.  ; Serveur DNS secondaire pour afrique.iut

amerique.iut.   IN  NS      ns1.amerique.iut. ; Serveur DNS principal pour amerique.iut
amerique.iut.   IN  NS      ns2.amerique.iut. ; Serveur DNS secondaire pour amerique.iut

asie.iut.       IN  NS      ns1.asie.iut.     ; Serveur DNS principal pour asie.iut
asie.iut.       IN  NS      ns2.asie.iut.     ; Serveur DNS secondaire pour asie.iut

mandarine.iut.  IN  NS      ns1.mandarine.iut.; Serveur DNS principal pour mandarine.iut
mandarine.iut.  IN  NS      ns2.mandarine.iut.; Serveur DNS secondaire pour mandarine.iut

; Enregistrements A pour les serveurs DNS des sous-domaines
ns1.afrique.iut.    IN  A  10.0.0.2     ; Serveur DNS principal Afrique
ns2.afrique.iut.    IN  A  10.0.0.20    ; Serveur DNS secondaire Afrique

ns1.amerique.iut.   IN  A  10.64.0.2    ; Serveur DNS principal Amérique
ns2.amerique.iut.   IN  A  10.64.0.5   ; Serveur DNS secondaire Amérique

ns1.asie.iut.       IN  A  10.128.0.2   ; Serveur DNS principal Asie
ns2.asie.iut.       IN  A  10.128.0.5   ; Serveur DNS secondaire Asie

ns1.mandarine.iut.  IN  A  10.192.0.2   ; Serveur DNS principal Mandarine
ns2.mandarine.iut.  IN  A  10.192.0.6   ; Serveur DNS secondaire Mandarine

; Optionnel : enregistrement pour le domaine iut lui-même
@          IN      A      10.192.0.5          ; Le domaine iut pointe vers ns1.iut
TATA

cat << AFR > /etc/bind/db.10-ptr
;
; Zone PTR file for iut
;
\$TTL 604800
@       IN      SOA     ns1.iut. admin.iut. (
                              2024112503    ; Numéro de série
                              604800        ; Rafraîchissement
                              86400         ; Réessai
                              2419200       ; Expiration
                              604800 )      ; Cache négatif TTL

@        IN      NS      ns1.iut.
@        IN      NS      ns2.iut.

2.0.0       IN      PTR     ns1.afrique.iut.
20.0.0      IN      PTR     ns2.afrique.iut.
2.0.64      IN      PTR     ns1.amerique.iut.
5.0.64      IN      PTR     ns2.amerique.iut.
2.0.128     IN      PTR     ns1.asie.iut.
5.0.128     IN      PTR     ns2.asie.iut.
2.0.192     IN      PTR     ns1.mandarine.iut.
6.0.192     IN      PTR     ns2.mandarine.iut.
5.0.192     IN      PTR     ns2.iut.
50.0.192    IN      PTR     ns2.iut.
AFR

cat << DNS > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";

    dnssec-validation auto;

    recursion yes;
    
    allow-recursion { any; }; 

    listen-on-v6 { any; };

    listen-on { any; }; 
};
DNS

systemctl restart named.service
