## Semaine du 01/10/24 au 04/20/24

### Mardi 01/10/24

- Création et aménagement de l'arboresence.  
- Relecture et appropriation du sujet.  
- Première version de maquettage d'infrastructure avec younes et valentin. 

### Mercredi 02/10/24

- Réunion avec les autres equipes et l'equipe FAI pour expliquer l´architecture réseau de chacun des organismes.  
- Cablage et configuration des switchs, du routeur (vlan et gateway) et attribution des ip de nos differents reseaux prives (services) a nos machines avec Valentin et Younes.  
- Problème sur le routage entre nos differents reseaux prives nous travaillons sur le sujet.

### Jeudi 03/10/24

- Résolution du routage entre nos differents réseaux privés avec Valentin et younes.  
- Début de la rédaction de documentation concernant l'architecture de notre réseau privé.  

### Vendredi 04/10/24

- Réflexion sur la conception de notre partie public.

### Lundi 14/10/24

- Rédaction de la documentation plus poussé (procédé et raisonnement) pour l'architecture réseau.
- Réléxion et début de la mise en place du DHCP et DNS avec Valentin.

### Mardi 15/10/24

- Rédaction de script automatise de configuration réseau pour les machines douglas (attribution d'ip & routage) avec Valentin.  
- Continuité de la mise en place du DHCP avec la création du vagrantfile.

### Mercredi 16/10/24

Pas de travail.

### Jeudi 17/10/24

- Fin de la mise en place du serveur DHCP à l'aide de Younes.  
- Rédaction de la documentation pour la mise en place du serveur web (fait par Younes) ainsi que DNS dans le réseau public.  
- Configuration du DNS fait avec Valentin mais pas encore testé car l'équipe FAI n'étant pas là ce jour.  
Réorganisation de l'arboresence.  

### Mardi 12/11/24

- Rédaction de la documentation pour le déploiement des stations de travail & DNS (modification, clarification de quelques doc nginx,dhcp).  
- Ajout d'une première version du Vagrantfile pour déployer les stations de travail.  
- Réflexion et début de la mise en place du NFS

### Mercredi 13/11/24

Malade

### Jeudi 14/11/24

- Modification du script pour prendre en compte la configuration du réseau publique.  
- Réorganisation de l'arboresence  
- TENTATIVE DE RESOLUTION DE NOTER PB DHCP AVEC TOUTE L'EQUIPE (EN VAIN).... bloqué toute la journée dessus approximativement 
- Documentation sur nos tentatives de résolution DHCP

### Mardi 26/11/24

- Documentation sur la mise en place du NFS.
- Réarrangement, optimisation et mise à jour des vagrantfile avec des provisions shell externalisés.
- Ajout d'un serveur slave DNS pour le domaine amerique.iut

### Mercredi 27/11/24

- Correction de coquilles, le DNS est mis en place et fonctionnel.
- Continuité de la mise en place du LDAP avec Valentin.
- Rédaction de documentation LDAP, archi réseau 

### Mardi 10/12/24

- Mise en place de l'intégration NFS avec LDAP et rédaction de la documentation 

### Mercredi 11/12/24

- Schéma de l'infrastructure avec mermaid

### Jeudi 12/12/24

- Finalisation de l'intégration LDAP et NFS
- Stations de travail en place et opérationnelle (il reste encore un soucis d'ajout de route et dns dans le provisionning)
- Complétion de documentations sur les stations de travail, ldap, nfs, serveur web.