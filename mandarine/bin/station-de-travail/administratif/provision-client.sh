#!/bin/bash

LDAP_SERVER="ldap://192.168.57.4"
BASE_DN="dc=mandarine,dc=iut"
BIND_DN="cn=admin,dc=mandarine,dc=iut"
BIND_PW="admin"

sudo apt update && sudo apt upgrade -y


#sudo apt install -y ldap-utils libnss-ldapd libpam-ldapd nscd

sudo DEBIAN_FRONTEND=noninteractive apt install -y libnss-ldap libpam-ldap ldap-utils nscd

debconf-set-selections <<EOF
libnss-ldap libnss-ldap/ldap-server string ldap://192.168.57.4/
libnss-ldap libnss-ldap/ldap-base string dc=mandarine,dc=iut
libnss-ldap libnss-ldap/nsswitch note
EOF

# Configuration manuelle du fichier /etc/nslcd.conf

echo "Configuration du serveur LDAP dans /etc/nslcd.conf..."

echo "uri ldap://192.168.57.4/
base dc=mandarine,dc=iut
binddn cn=admin,dc=mandarine,dc=iut
bindpw admin
ssl off
bind_timelimit 10" | sudo tee /etc/nslcd.conf > /dev/null

sudo systemctl restart nslcd

#Chercher la configue auto pour nscd


# -----------------> Configurer NSS pour utiliser LDAP
sudo sed -i 's/^passwd:.*/passwd:         files ldap/' /etc/nsswitch.conf
sudo sed -i 's/^group:.*/group:          files ldap/' /etc/nsswitch.conf
sudo sed -i 's/^shadow:.*/shadow:         files ldap/' /etc/nsswitch.conf

#--------------------> Configue pam

#sudo pam-auth-update
echo "session     required      pam_mkhomedir.so skel=/etc/skel umask=0022" | sudo tee -a /etc/pam.d/common-session > /dev/null
echo "Configuration terminée."
