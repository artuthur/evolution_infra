---
title: Mise en place du serveur pare-feu et sécurisation du réseau
---


### Pourquoi utiliser un pare-feu ?

Un pare-feu est un appareil de protection du réseau qui surveille le trafic entrant et sortant, et décide d'autoriser ou de bloquer une partie de ce trafic en fonction d'un ensemble de règles de sécurité prédéfinies. Les pare-feu constituent la première ligne de défense des réseaux.

### Pourquoi utiliser Stormshield ?

Les pare-feu Stormshield se distinguent tous par la facilité de leur mise en place. Et leur interface graphique assure une gestion et administration simplifiée, comme indiqué sur leur site internet.

# Réinitialiser le pare-feu Stormshield

Il est possible de restaurer la configuration usine d’un pare-feu Stormshield Network Security. Cette opération ramène alors le produit dans la version initiale de sa configuration. Cette réinitialisation ne modifie pas la version du firmware et ne concerne que la partition active. Il faut se munire d'un petit stylo par exemple et rester appuyer longtemps sur le petit bouton derrière le pare-feu "default config" ci-dessous.

![inout](amerique/doc/img/stormshield_screen/inout.png)

Après quelques minutes, le pare-feu retrouve sa configuration usine et redémarre. Cette réinitialisation peut durer jusqu’à 10 minutes, il faut attendre la fin du redémarrage pour nous reconnecter au pare-feu. Il faut ettendre que les 3 LEDS soient allumées. 

![leds](amerique/doc/img/stormshield_screen/leds.png)

# Mise en place du serveur pare-feu Stormshield

Dans le but d'initialiser le pare-feu, il est nécessaire de brancher un poste client au pare-feu sur son interface IN (voir le schéma au dessus pour savoir la bonne interface), ainsi que t'attribuer une ip du réseau 10.0.0.0/8 au poste client afin d'avoir accès à l'interface web d'installation avec https:10.0.0.254/admin/install.html depuis un navigateur web. L'identifiant et mot de passe de base est "admin"

Puis, lors de la configuration de base, nous allons lui indiquer une ip externe qui sera son ip sur l'interface out "de sortie" ainsi que sa passerelle pour aller sur le réseau public.

![screen1](amerique/doc/img/stormshield_screen/storm1.png)

Nous allons également lui donner une ip interne sur son interface "in", le pare-feu ne nous demande pas de renseigner les passerelles internes lors de l'installation, par conséquent, nous n'aurons pas accès pour le moment au pare-feu avec nos réseau privées interne tel qu'informatique.

![screen2](amerique/doc/img/stormshield_screen/storm2.png)

On lui indique notre nom de domaine.

![screen3](amerique/doc/img/stormshield_screen/storm3.png)

Un mot de passe pour se connecter par la suite à l'interface web.

![screen4](amerique/doc/img/stormshield_screen/storm4.png)

Dans cette étape, le pare-feu va être mis à jour, si nous sommes certains des paramètre renseigner précédemment, nous pouvons cliquer sur "apply and shutdown the appliance", le pare-feu va se mettre à jour, il met beaucoup de temps à se mettre à jour et à rédémarrer. Il faut bien attendre que les 3 LEDS soient allumées pour ensuite se connecter au pare-feu.

![screen5](amerique/doc/img/stormshield_screen/storm5_au_milieu_shutdown.png)

# Accès au pare-feu avec l'interface web depuis les autres réseaux et activer leur protection

Nous pouvons brancher notre pare-feu à notre baie réseau, entre nos 2 routeurs, entre nos 2 VLAN d'interconnexion, en faisant attention au sens du "in" et du "out"
Désormais, nous avons notre pare-feu configuré avec ses nouvelles ip et inséré dans notre baie, mais nous ne pouvons pas encore nous connecter dessus depuis l'interface web avec par exemple notre poste client dans le réseau informatique, car il ne sont pas dans le même réseau, pour cela il faudra d'abord se connecter à l'interface web, en brancher son poste client au routeur "in" et mettre au poste client une ip du même VLAN où se trouve le pare-feu, donc du même réseau que le pare-feu pour pouvoir aller sur son interface web. Une fois sur l'interface web nous allons lui renseigner les passerelles de nos différents réseaux à protéger, une fois cela fait nous pourrons nous connecter au pare-feu depuis nos différents réseaux avec https://< IpDuParefeu >/admin depuis un navigateur web.


![screen10](amerique/doc/img/stormshield_screen/routefirewall.png)



# Les règles de filtrages

Pour effectuer des règles de filtrage, il est nécessaire de configurer au préalable des "objets" qui seront utilisés pour identifier nos clients, nos réseaux dans la table de filtrage.

![screen8](amerique/doc/img/stormshield_screen/storm8.png)

Voici notre table de filtrage, lorsque l'on fait des règles, il faut indiquer au pare-feu les 2 sens differents pour que le trafic circule, sauf lorsque c'est une destination en "protocole IP", où là le pare-feu reconnaîtra lui même la source et l'autorisera lui même avoir à lui donner une règle de retour.

On termine avec une règle de sécurité en bloquant tout le trafic, en dernier, car l'ordre à une très grande importance, si nous mettons cette règle en première les autres ne seront pas activés, le pare-feu prends en considération en priorité les premières règles actives "LEDS vertes".

![screen10](amerique/doc/img/stormshield_screen/regledu10janvier.png)

#### Sauvegarde de la configuration du pare-feu

Il y a également une rubrique, "Maintenance" où l'on peut retrouver le "Backup" afin de sauvegarder la configuration du pare-feu dans des fichiers ".NA".


![screen10](amerique/doc/img/stormshield_screen/screensave.png)

## Retour au sommaire

- [Retourner au sommaire](../../README.md#documentations---liens-rapide)


 