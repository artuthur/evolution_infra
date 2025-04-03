#!/bin/bash
PASSWORD="admin"

hostnamectl set-hostname ldap

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

echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian/ bookworm main contrib non-free" >> /etc/apt/sources.list

echo "192.168.57.4 ldap" >> /etc/hosts
# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer OpenLDAP et les outils

apt-get -yq install vim
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils

sudo rm -rf /var/lib/ldap/*

# Configuration automatique de slapd
echo "slapd slapd/internal/generated_adminpw password $PASSWORD" | sudo debconf-set-selections
echo "slapd slapd/internal/adminpw password $PASSWORD" | sudo debconf-set-selections
echo "slapd slapd/password2 password $PASSWORD" | sudo debconf-set-selections
echo "slapd slapd/password1 password $PASSWORD" | sudo debconf-set-selections
echo "slapd slapd/domain string mandarine.iut" | sudo debconf-set-selections
echo "slapd shared/organization string mandarine.iut" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive slapd

sudo mkdir -p /srv/ldap/iut

# Ajouter un fichier LDIF pour la base
cat <<EOF > /srv/ldap/iut/base.ldif
dn: ou=users,dc=mandarine,dc=iut
objectClass: organizationalUnit
ou: users

dn: ou=users-administratif,dc=mandarine,dc=iut
objectclass: organizationalunit
ou: administratif

dn: ou=users-informatique,dc=mandarine,dc=iut
objectclass: organizationalunit
ou: users-informatique

dn: uid=admin,ou=users-administratif,ou=users-informatique,dc=mandarine,dc=iut
objectClass: inetOrgPerson
objectClass: shadowAccount
cn: LDAP Admin
sn: Admin
uid: admin
userPassword: admin
homeDirectory: /home/admin
EOF


echo "Debut du ldap ADD"
sleep 5
# Ajouter la base au serveur LDAP
sudo ldapadd -D "cn=admin,dc=mandarine,dc=iut" -w "$PASSWORD" -f /srv/ldap/iut/base.ldif
sudo ldapadd -D "cn=admin,dc=mandarine,dc=iut" -w "$PASSWORD" -f /vagrant/personne.ldif
