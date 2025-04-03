# Compte rendu journalier Etudiant B

## 2024/09/30
- Formation des groupes
- Compréhension du sujet et des attendus

## 2024/10/01
- Début des recherches sur l'organisation de l'infrastructure réseau que nous allons mettre en place, surtout pour la partie du réseau public, puisque nous sommes l'équipe FAI
- Câblage + configuration des routeurs et switchs pour la mise en place du réseau public

## 2024/10/02
- Nous avons recherché une nouvelle solution pour le réseau public, car après retour des autres équipes, la solution que nous avions choisie présentait des erreurs et le réseau public était inutilisable

## 2024/10/03
- Solution trouvée pour le réseau public
    + Câblage + configuration des routeurs et switchs
    + Test de la solution avec d'autres équipes pour vérifier que tout fonctionne correctement
- Début des documentations et des procédures des différentes configurations effectuées

## 2024/10/04
- Remise au propre du réseau sur papier pour que ce soit plus clair

## 2024/10/14
- Remise en place du réseau (cables, conf des routeurs, switch)
- Mise en place du reéseau privé informatique et administratif
- Début de reflexion sur la mise en place du serveur DNS `iut` et `mandarine` 

## 2024/10/15
- Mise en place du serveur web ([voir Vagrantfile](../../bin/srv-web/Vagrantfile))
- Mise en place des dns :
    * [voir dns iut](../../bin/dns-iut/dns-iut.sh)
    * [voir dns mandarine](../../bin/dns-mandarine/dns-mand.sh)

## 2024/10/16

## 2024/10/17
- JMI
- Mise à jour des dns
- Création d'une procédure pour le dns iut

## 2024/10/18
- Création d'une procédure pour le dns mandarine
- Création d'une procédure pour le serveur web

## 2024/11/12  
- Correction et modification sur les DNS IUT et Mandarine.  

## 2024/11/13  
- Tests des DNS avec les différentes organisations et correction des problèmes rencontrés.  

## 2024/11/14  
- Vérification du DHCP et correction du routeur 2 pour ajouter le **ip-helper**.  

## 2024/11/15  

## 2024/11/25  
- Création du script de provisionnement des machines.  
- Modification des fichiers de configuration des DNS.  

## 2024/11/26  
- Réflexion sur la mise en place et la configuration du firewall.  

## 2024/11/27  
- Mise en place et configuration du firewall.  

## 2024/11/28  
- Fin de la configuration du firewall (pas encore de règle de filtrage installée).  
- Réalisation du schéma réseau du réseau public.  

## 2024/11/29  
- Début de la réflexion sur le serveur mail.  

## 2024/12/09
- Réflexion sur le serveur et test de déploiement
- Pas de serveur mail déployer

## 2024/12/10
- Mise en place du serveur mail avec postfix, MariaDB et Dovecot
- Modification des fichiers de configuration du dns mandarine pour un bon fonctionnement du serveur mail

## 2024/12/11
- Réalisation de documentation gerer le serveur mail

## 2024/12/12
- Réalisation de procédure pour l'installation et la configuration du serveur mail

## 2024/12/13
- Finalisation de la procédure du jeudi + début d'écriture de la procédure pour ajouter un poste dans les différents reseaux

## 2025/01/06
- Remise en place du serveur mail
- Mise en place de la configuration necessaire pour que l'on puisse envoyer des mails chez des autres organisations
- Le réseau privée et notre réseau publique peuvent communiqué ensemble

## 2025/01/07
- Fin de mise en place du serveur mail et web pour que l'on puisse acceder à Rainloop avec l'adresse suivante : http://mail.mandarine.iut
- Aide pour refaire la procédure de l'installation et la configuration du firewall
- Début de mise à jour de la documentation du DNS

## 2025/01/08
- Resolution de problème de route pour les machines virtuelles et machines physiques
- Mise à jour du dhcp qui nous permet de donner le dns et des routes
- Début de mise en place des machines virtuelles avec interface graphique

## 2025/01/09
- Fin de la mise en place des interfaces graphiques avec la mise en place des routes dans le fichier /etc/network/interfaces
- Début de reflexion sur la mise en place d'un DNS de secours pour le dns mandarine et iut
- Mise à jour du DNS iut et mandarine pour y ajouter les serveurs dns de secours des autres organisations
- Correctif du DNS mandarine

## 2025/01/10
- Test de destroy et de re-up toutes les machines
- Contre rendu de ce qu'il reste a faire pour finir les besoins
- Mise en place d'un DNS mandarine de secours avec ses tests tout est OK
- Début de reflexion et de mise en place pour un DNS iut de secours
- Correctif des petits problèmes lors de la remise en place des machines
- Réecruture du dossier provision pour les déploiements des machines

## 2025/01/17
- Remise en place de l'infrastructure après le passage des profs

## 2025/01/18
- Création du schéma de notre réseau publique et privé

## 2025/01/19
- Ecriture de documentation pour :
    * Serveur dns iut
    * Serveur dns mandarine
    * Serveur dns iut secours
    * Serveur dns mandarine secours

## 2025/01/20
- Remise en place des machines
- Ecriture de documentation pour :
    * Serveur mail
    * Installation de spamassassin
    * Mise en place DHCP
- Finalisation des machines stations de travail
- Correction petit problème sur le serveur dhcp qui ne donnait d'ip pour le réseau 192.168.58.0/24
- Modification de règles du firewall
- Mise en place de spamassassin
- Modif du README.md

## 2025/01/21
- Dernier test de spamassassin pour le serveur mail
- Mise en place des stations de travail
- Derniere verification des diférents services
- Corrections de documentations

## 2025/01/22
- Correction des PTR pour le dns iut
- Dernier test avec les machines de travail
- Corrections de documentations
- Evaluation avec les profs