apt-get install nfs-common -y

ip r add 10.0.0.0/8 via 192.168.57.1 dev eth1
ip r add 192.168.56.0/22 via 192.168.57.1 dev eth1

cat << DNS > /etc/resolv.conf
nameserver 10.192.0.2
nameserver 10.192.0.6
DNS

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

IP=$(ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+\.\d+\.\d+')

if [[ "$IP" == "192.168.57" || "$IP" == "192.168.58" ]]; then
  mkdir -p /home/informatique
  echo "192.168.57.3:/srv/nfs/home/informatique /home/informatique nfs rw,sync,no_subtree_check,no_root_squash 0 0" >> /etc/fstab
  mount -t nfs 192.168.57.3:/srv/nfs/home/informatique /home/informatique
  mkdir -p /home/administratif
  echo "192.168.57.3:/srv/nfs/home/administratif /home/administratif nfs rw,sync,no_subtree_check,no_root_squash 0 0" >> /etc/fstab
  mount -t nfs 192.168.57.3:/srv/nfs/home/administratif /home/administratif
fi

