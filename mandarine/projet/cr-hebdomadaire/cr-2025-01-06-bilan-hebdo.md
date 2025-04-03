# Semaine 6
---

## Tâches effectuées
- Remise en place du serveur mail puis ajout de la fonctionnalité pour lui permettre l'envoie des mails vers d'autres organisations
- Mise en place des règles de filtrage pour le Firewall
- Mise en place d'un DNS mandarien de secours puis début de reflexion et mise en place d'un DNS iut de secours 
- Mise en place de LDAP et NFS
- Mise en place d'une machine station de travail avec interface graphique
- Modification de la configuation du DHCP pour lui permettre de donner le DNS et les routes

## Points bloquants
- Nous avons rencontrés quelque soucis avec certaines reglès du Firewall qui bloqué trop de chose 

## Tâches planifiées pour la semaine prochaine
- Resolution des problèmes de zone PTR pour le DNS iut
- Essayer de mettre en place un DNS de secours pour le domaine IUT quand le DNS principal sera opérationnel
- Finir la mise en place des stations de travails surtout au niveau des routes qui sont à écrire dans le fichier /etc/network/interfaces
- Regarder si toutes les règles sont correctes pour le Firewall
- Faire que la resoltion DNS puisse passer dans le réseaux privé  (C'était le cas en début de semaine mais maintenant nous ne savons plus)
- Finir de faire les dernières procédures
- Si tout est terminé, essaie de mettre en place les IPv6