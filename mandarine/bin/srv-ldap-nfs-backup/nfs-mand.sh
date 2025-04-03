apt-get update
apt-get install -qy nfs-kernel-server

ip r add 10.0.0.0/8 via 192.168.57.1 dev eth1
ip r add 192.168.56.0/22 via 192.168.57.1 dev eth1

cat << DNS > /etc/resolv.conf
nameserver 10.192.0.2 
DNS


mkdir -p /srv/nfs/home/administratif /srv/nfs/home/informatique

chown vagrant:vagrant /srv/nfs/home/administratif /srv/nfs/home/informatique
chmod 777 /srv/nfs/home/administratif /srv/nfs/home/informatique

cat <<-AZE >> /etc/exports
/srv/nfs/ *(rw,sync,no_subtree_check,no_root_squash,fsid=0)
/srv/nfs/home/informatique 192.168.57.0/24(rw,sync,no_subtree_check,no_root_squash)
/srv/nfs/home/administratif 192.168.58.0/24(rw,sync,no_subtree_check,no_root_squash)
AZE

systemctl restart nfs-server
