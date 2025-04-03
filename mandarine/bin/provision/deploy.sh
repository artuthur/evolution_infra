#!/bin/bash

# Fonction pour afficher l'aide
function afficher_aide() {
cat << EOF
usage: ./deploy.sh [OPTIONS]

Ce script déploie la configuration réseau et lance une machine virtuelle 
correspondant au numéro choisi. 
Le numéro :
    * 1 Correspond pour Douglas01 et va créer les machines nécessaires
      pour le réseau public : serveurs dns-iut, dns-mandarine, dns-iut-secours,
      dns-mandarine-secours et mail/web.

    * 2 Correspond pour Douglas02 et va créer les machines nécessaires
      pour le réseau privé : serveurs NFS, LDAP, DHCP et une station de travail.

    * 3 Correspond pour Douglas03 : cette machine sera mise sur le réseau 
      130.130.2.0/24 pour permettre l'accès à l'interface graphique du routeur.

    * 4 Correspond pour Douglas04 et va créer les machines nécessaires
      pour le réseau privé avec deux stations de travail nommées France 
      et Belgique.

OPTIONS :
    -h, --help   affiche ce message d'aide
EOF
}

# Gestion des options
if [[ "$#" -eq 1 && "$1" == "-h" ]] || [[ "$#" -eq 1 && "$1" == "--help" ]]; then
    afficher_aide
    exit 0
elif [[ "$#" -gt 0 ]]; then
    echo "Erreur: Argument non reconnu : $1\n"
    echo "Pour plus d'aide veuillez taper la commande suivante : ./deploy.sh -h ou ./deploy.sh --help"
    exit 1
fi

# Récupère le nom et l'adresse ip de la machine
printf "\n\nQuel est le numéro sur la machine auqelle vous-êtes installer. \nUne fois le numéro entré, tapez sur la touche 'entrer' pour confirmer.\n"
read MACHINE_NAME
echo Vous avez choisie le numéro suivant: $MACHINE_NAME

if [ "$MACHINE_NAME" = '1' ]
then
    printf "Le script a identifié $MACHINE_NAME, donc il procédera à l'installation de ce dernier pour la machine Douglas0$MACHINE_NAME.\nLa machine sera sur le reseau 10.192.0.0/16 qui correspond à celui du reseau publique\n"
    sleep 3
    
    sudo ip addr add 10.192.0.10/16 dev enp3s0
    sudo ip route add 10.0.0.0/8 via 10.192.0.254 dev enp3s0

    cd ./Douglas0$MACHINE_NAME
    vagrant up

    echo "Configuration de la machine fini"
elif [ "$MACHINE_NAME" = '2' ]
then
    printf "Le script a identifié $MACHINE_NAME, donc il procédera à l'installation de ce dernier pour la machine Douglas0$MACHINE_NAME.\nLa machine sera sur le reseau 192.168.57.0/24 qui correspond à celui de l'informatique\n"
    sleep 3
    
    sudo ip addr add 192.168.57.2/24 dev enp3s0
    sudo ip route add 192.168.56.0/22 via 192.168.57.1 dev enp3s0
    sudo ip route add 10.0.0.0/8 via 192.168.57.1 dev enp3s0
    sudo ip route add 130.130.0.0/16 via 192.168.58.1 dev enp3s0

    cd ./Douglas0$MACHINE_NAME
    vagrant up

    echo "Configuration de la machine fini"
elif [ "$MACHINE_NAME" = '3' ]
then
    printf "Le script a identifié $MACHINE_NAME, donc il procédera à l'installation de ce dernier pour la machine Douglas0$MACHINE_NAME\n"
    sleep 3
    
    sudo ip addr add 130.130.2.5/24 dev enp3s0
    sudo ip route add 192.168.58.0/24 via 192.168.57.1 dev enp3s0

    cd ./Douglas0$MACHINE_NAME
    vagrant up

    echo "Configuration de la machine fini"
elif [ "$MACHINE_NAME" = '4' ]
then
    printf "Le script a identifié $MACHINE_NAME, donc il procédera à l'installation de ce dernier pour la machine Douglas0$MACHINE_NAME.\nLa machine sera sur le reseau 192.168.58.0/24 qui correspond à celui de l'administratif\n"
    sleep 3
    
    sudo ip addr add 192.168.57.2/24 dev enp3s0
    sudo ip route add 192.168.56.0/22 via 192.168.57.1 dev enp3s0
    sudo ip route add 10.0.0.0/8 via 192.168.57.1 dev enp3s0
    sudo ip route add 130.130.0.0/16 via 192.168.58.1 dev enp3s0

    cd ./Douglas0$MACHINE_NAME
    vagrant up
else
    echo "Le programme arrête la configuration ici car le nom de la VM n'est pas connu"
fi
