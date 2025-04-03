## Compte-rendu hebdomadaire - Semaine 04

#### Tâches effectuées :

-mise en place du proxy

-connexion entre notre réseau privé et public

-script pour avoir des routes persistantes

-dhcp avec adresses mac

-dns master et récursif avec FAI

-installation du firewall

-nfs v3

-documentation


#### Points bloquants rencontrées  :

-dns esclave qui ne fonctionne pas 

-ldap qui n'est pas encore opérationnel

-pour le nfs, lors des changement de droit sur le répertoie /home/ cela bloque la connexion ssh avec vagrant 


#### Tâches à venir :
-règles sur le firewall car pour le moment il bloque tout le trafic entre le privée et le public

-dns esclave

-ldap avec le lien nfs 

-script d'automatisation pour directement lancer les routes persistances en 1 seule commande, car on ne peut pas l'éxécuter directement dans avec vagrant up car il ne veut pas qu'on redémmare les interfaces réseau