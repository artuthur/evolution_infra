# Voici les commandes pour check les conf sur serveur dns iut 
named-checkconf

named-checkzone iut /etc/bind/db.iut
named-checkzone 0.0.10.in-addr.arpa /etc/bind/db.10.0.0-ptr
named-checkzone 0.64.10.in-addr.arpa /etc/bind/db.10.64.0-ptr
named-checkzone 0.128.10.in-addr.arpa /etc/bind/db.10.128.0-ptr
named-checkzone 0.192.10.in-addr.arpa /etc/bind/db.10.192.0-ptr