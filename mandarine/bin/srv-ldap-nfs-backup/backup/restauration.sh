#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Ce script extrait des fichiers de sauvegarde compressés avec bzip2 et les restaure sur un serveur distant via SSH."
    echo
    echo "Usage : $0 [option]"
    echo "Options :"
    echo "  -h, --help    Affiche cette aide."
    exit 0
fi

bzip2 -dc /mnt/data/srvnfs.1.bz2 | ssh srvnfs "cd /; restore -xof -"
bzip2 -dc /mnt/data/ldap.1.bz2 | ssh srvnfs "cd /; restore -xof -"