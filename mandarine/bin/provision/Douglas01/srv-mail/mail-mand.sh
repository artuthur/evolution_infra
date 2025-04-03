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
ip r add 10.0.0.0/8 via 10.192.0.254 dev eth1
ip r add 192.168.56.0/22 via 10.192.0.254 dev eth1

# On modifie l'ip du nameserver
cat << TETE > /etc/resolv.conf
nameserver 10.192.0.2
nameserver 10.192.0.6
TETE

cat << EOF >> /etc/hosts
# Partie publique
10.192.0.2 dns-mandarine.iut
10.192.0.3 mail.mandarine.iut
10.192.0.3 web.mandarine.iut
10.192.0.5 dns-iut
10.192.0.6 dns-mandarine.iut-sec
10.192.0.50 mail-mand

#Partie privé
192.168.57.3 dhcp
192.168.57.4 ldap
192.168.57.5 nfs
EOF