#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    cat <<EOF
Usage: provision_mail [OPTIONS]

Résumé :
    Ce script configure automatiquement un serveur mail avec Postfix et Dovecot, en utilisant LDAP pour l'authentification.

Description :
    - Installe les paquets nécessaires pour un serveur mail (postfix, dovecot-core, etc.).
    - Configure Postfix pour utiliser des maps LDAP pour les utilisateurs et les expéditeurs.
    - Configure Dovecot pour l'authentification IMAP avec LDAP.
    - Définit le fichier `/etc/resolv.conf` avec des serveurs DNS spécifiques.
    - Ajoute une route statique vers le réseau `10.0.0.0/8` via `eth1`.
    - Déclare le nom d'hôte `mail.amerique.iut`.
    - Crée l'utilisateur système `vmail` pour gérer les boîtes aux lettres virtuelles.

Options:
    -h, --help        Affiche ce message d'aide.

EOF
}

# Vérifie si l'option -h ou --help est passée en paramètre
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    afficher_aide
    exit 0
elif [[ "$1" != "" && "$1" != "-h" && "$1" != "--help" ]]; then
    echo "Argument invalide : $1  veuillez utiliser -h ou --help pour plus d'informations"
    exit 1
fi

sudo apt-get update -y


echo -e "nameserver 10.64.0.2\nnameserver 10.64.0.5" | sudo tee /etc/resolv.conf > /dev/null


ip route add 10.0.0.0/8 dev eth1


hostnamectl set-hostname mail.amerique.iut


echo "postfix postfix/mailname string amerique.iut" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections


DEBIAN_FRONTEND=noninteractive apt install -y postfix-ldap dovecot-core dovecot-ldap dovecot-imapd



cat <<EOL > /etc/postfix/sender_login_maps.cf
server_host      = 10.64.0.1
server_port      = 389
bind             = yes
start_tls        = no
version          = 3
bind_dn          = cn=admin,dc=amerique,dc=iut
bind_pw          = azerty
search_base      = dc=amerique,dc=iut
scope            = sub
query_filter     = (mail=%s)
result_attribute = mail
EOL

cat <<EOL > /etc/postfix/virtual_mailbox_maps.cf
server_host      = 10.64.0.1
server_port      = 389
bind             = yes
start_tls        = no
version          = 3
bind_dn          = cn=admin,dc=amerique,dc=iut
bind_pw          = azerty
search_base      = dc=amerique,dc=iut
scope            = sub
query_filter     = (&(mail=%s)(objectClass=inetOrgPerson))
result_attribute = mail
result_format    = /home/vmail/%d/%u/mailbox/
debuglevel       = 0
EOL


cat <<EOL > /etc/postfix/main.cf
smtpd_banner = \$myhostname ESMTP
biff = no
append_dot_mydomain = no
compatibility_level = 3.6

myhostname = mail.amerique.iut
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = \$myhostname, localhost
relayhost = 
mynetworks = 127.0.0.0/8 
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = all

smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
smtpd_sasl_auth_enable = yes
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth_dovecot
smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination

virtual_mailbox_base = /home/vmail/
virtual_uid_maps = static:5000
virtual_gid_maps = static:5000
virtual_transport = dovecot
virtual_mailbox_domains = \$mydomain
smtpd_sender_login_maps = ldap:/etc/postfix/sender_login_maps.cf
virtual_mailbox_maps = ldap:/etc/postfix/virtual_mailbox_maps.cf

local_recipient_maps = \$virtual_mailbox_maps
EOL

cat <<EOL > /etc/postfix/master.cf
smtp      inet  n       -       -       -       -       smtpd
submission inet n       -       -       -       -       smtpd
  -o smtpd_tls_security_level=none
pickup    fifo  n       -       -       60      1       pickup
cleanup   unix  n       -       -       -       0       cleanup
qmgr      fifo  n       -       n       300     1       qmgr
tlsmgr    unix  -       -       -       1000?   1       tlsmgr
rewrite   unix  -       -       -       -       -       trivial-rewrite
bounce    unix  -       -       -       -       0       bounce
defer     unix  -       -       -       -       0       bounce
trace     unix  -       -       -       -       0       bounce
verify    unix  -       -       -       -       1       verify
flush     unix  n       -       -       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       -       -       -       smtp
relay     unix  -       -       -       -       -       smtp
showq     unix  n       -       -       -       -       showq
error     unix  -       -       -       -       -       error
retry     unix  -       -       -       -       -       error
discard   unix  -       -       -       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       -       -       -       lmtp
anvil     unix  -       -       -       -       1       anvil
scache    unix  -       -       -       -       1       scache
dovecot   unix  -       n       n       -       -       pipe
  flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/deliver -d \${recipient}
EOL


cat <<EOL > /etc/postfix/transport
amerique.iut dovecot
EOL
postmap hash:/etc/postfix/transport


mkdir -p /etc/dovecot
cat <<EOL > /etc/dovecot/dovecot.conf
auth_mechanisms = plain login
disable_plaintext_auth = no
mail_uid = vmail
mail_gid = vmail
login_log_format_elements = "user=<%u> method=%m rip=%r lip=%l mpid=%e %c %k"
protocols = imap
listen = *

userdb {
  args = /etc/dovecot/dovecot-ldap-user.conf.ext
  driver = ldap
}
passdb {
  args = /etc/dovecot/dovecot-ldap-pass.conf.ext
  driver = ldap
}

service auth {
  unix_listener /var/spool/postfix/private/auth_dovecot {
    group = postfix
    mode = 0660
    user = postfix
  }
  unix_listener auth-userdb {
    mode = 0600
    user = vmail
  }
  user = root
}

service dict {
    unix_listener dict {
        mode = 0660
        user = vmail
        group = vmail
    }
}
EOL


cat <<EOL > /etc/dovecot/dovecot-ldap-user.conf.ext
hosts = 10.64.0.1
dn = cn=admin,dc=amerique,dc=iut
dnpass = azerty
debug_level = 0
auth_bind = no
ldap_version = 3
base = dc=amerique,dc=iut
scope = subtree
user_attrs = \
  =home=/home/vmail/%d/%{ldap:uid}, \
  =mail=maildir:/home/vmail/%d/%{ldap:uid}/mailbox
user_filter = (mail=%u)
iterate_attrs        = mail=user
iterate_filter       = (objectClass=person)
EOL

cat <<EOL > /etc/dovecot/dovecot-ldap-pass.conf.ext
hosts  = 10.64.0.1
dn = cn=admin,dc=amerique,dc=iut
dnpass = azerty
debug_level = 0
auth_bind = no
ldap_version = 3
base = dc=amerique,dc=iut
scope = subtree
pass_attrs = mail=user,userPassword=password
pass_filter = (&(mail=%u)(objectClass=person))
default_pass_scheme = PLAIN
EOL


groupadd --gid 5000 vmail
useradd -g vmail -u 5000 -d /home/vmail -m vmail
chown -R vmail:vmail /home/vmail
chmod 700 /home/vmail


systemctl restart postfix dovecot



sudo ip route add 10.0.0.0/8 dev eth1 2>/dev/null


