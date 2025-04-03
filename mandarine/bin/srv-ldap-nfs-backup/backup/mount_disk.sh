#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Ce script formate une partition en ext4, crée un répertoire de montage, et monte la partition sur ce répertoire."
    echo
    echo "Usage : $0 [option]"
    echo "Options :"
    echo "  -h, --help    Affiche cette aide."
    exit 0
fi

sudo mkfs.ext4 /dev/sdb
sudo mkdir -p /mnt/data
sudo mount /dev/sdb /mnt/data