## Compte-rendu hebdomadaire - Semaine 06

#### Tâches effectuées :

- Mise en place de serveur mail réussi
- Ldap automatique au lancement du provision
- Test de l'infrastructure, envoie mail aux autre groupes réussi
- Nouvelles règles du firewall avec sauvegarde
- Tentative de réparation du DNS2
- Complétion de documentation
- Résolution du problème "vagrant ssh" sur douglas07 avec Monsieur Beaufils
- Mise en place d'adresse mac fixe sur les vm du réseau public

#### Points bloquants rencontrées  :

- Problèmes de ping, sur le réseau public, on pouvait ping certaines machines et d'autres non, depuis les machines qui ne pouvait pas être ping, nous avons ping leur interface puis cela a fonctionné, sans que nous changions quoi que ce soit, nous avons mis des adresses mac fixe pour résoudre ce problème car il arrive à cause du fait que nous faisons plusieurs destroy de vm, et la table ARP des routeurs ne se met pas à jour assez rapidement, c'était également le cas du serveur mail qui ne pouvait pas trouver le serveur ldap à cause de cela, mais le problème est désormais résolu.
- Panne réseau de l'iut, au même moment le groupe asie et nous, n'avions plus accès à internet depuis les pc douglas physique, sans que nous ayons touché à l'interface de l'iut, puis c'est revenu au bout de 10 minutes, en même temps que le groupe asie.




#### Tâches à venir :

- Essaye de résoudre le problème de récursivité du DNS2
- Complétion de documentation
