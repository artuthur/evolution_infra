# !/bin/bash
ip r add 10.0.0.0/8 via 192.168.58.1 dev eth1
ip r add 192.168.56.0/22 via 192.168.58.1 dev eth1

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

# Ajouter des routes spécifiques dans /etc/network/interfaces
sudo sed -i '/post-up ip route del default dev \\$IFACE || true/a \\    up ip route add 10.0.0.0/8 via 192.168.58.1 dev eth1\\n    up ip route add 192.168.56.0/22 via 192.168.58.1 dev eth1' /etc/network/interfaces

# Mise à jour et installation des logiciels nécessaires
apt-get update -y && apt-get upgrade -y 
apt-get install -y xfce4 xfce4-goodies
apt-get install -y thunderbird thunderbird-l10n-fr
apt-get install -y firefox-esr firefox-esr-l10n-fr
apt-get install -y dbus-x11

# Configurer le clavier en français
sudo setxkbmap fr
sudo sed -i 's/XKBLAYOUT=\"\\w*\"/XKBLAYOUT=\"fr\"/g' /etc/default/keyboard

# Redémarrage pour appliquer la configuration du clavier
/vagrant/provision-client.sh
/vagrant/client-nfs.sh
sudo reboot