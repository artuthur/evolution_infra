apt-get install nfs-common -y

NAME=$(hostname)

if [[ "$NAME" == "clientInfo" ]]; then
    mkdir -p /home/informatique
    echo "192.168.57.3:/srv/nfs/home/informatique /home/informatique nfs rw,sync,no_subtree_check,no_root_squash 0 0" >> /etc/fstab
    mount -t nfs 192.168.57.3:/srv/nfs/home/informatique /home/informatique
elif [[ "$NAME" == "client" ]]; then
    mkdir -p /home/administratif
    echo "192.168.57.3:/srv/nfs/home/administratif /home/administratif nfs rw,sync,no_subtree_check,no_root_squash 0 0" >> /etc/fstab
    mount -t nfs 192.168.57.3:/srv/nfs/home/administratif /home/administratif
fi
