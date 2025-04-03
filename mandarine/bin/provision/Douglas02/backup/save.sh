#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Ce script crée des sauvegardes compressées (bzip2) des systèmes de fichiers racine"
    echo "de deux serveurs distants (srvnfs et ldap) et les stocke localement."
    echo
    echo "Usage : $0 [option]"
    echo "Options :"
    echo "  -h, --help    Affiche cette aide."
    exit 0
fi

ssh srvnfs "sudo dump -0u -f - /" | bzip2 -c > /mnt/data/srvnfs.1.bz2
ssh ldap "sudo dump -0u -f - /" | bzip2 -c > /mnt/data/ldap.1.bz2