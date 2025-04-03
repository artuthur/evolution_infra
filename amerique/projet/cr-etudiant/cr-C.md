1/10/2024


J'ai effectué une première maquette Cisco et parlé avec mon équipe de cela, où j'ai révisé plusieurs concepts importants, notamment :

    Les VLANs et le routage inter-VLANs,
    Le VTP (VLAN Trunking Protocol),
    La configuration de serveurs DHCP et DNS (sur maquette)
    Et les configurations de base des routeurs et switches.

4/10/2024

Nous avons mis en place le réseau privé, et j'ai réalisé une nouvelle maquette avec le réseau public avec le dhcp pour le réseau privée et dns fonctionnel hébérgé sur le public.
J'ai également commencé à rédiger de la doc.

14/10/2024

Le réseau public a été déployé avec succès dans l'infrastructure. Après test, la connectivité est confirmée : le PC public Amérique peut pinguer sans problème le PC public du groupe Afrique. Et nous avons remis le réseau privée qui avait été supprimé par les BUT2.

15/10/2024

Aujourd'hui, j'ai regardé comment configurer le DHCP et comment créer un bridge avec les interfaces de la machine physique afin d'éviter le problème rencontré avec Vagrant, qui demandait des adresses IP à partir du réseau du 56. Cette solution permet désormais d'éviter ce problème. De plus, nous avons commencé à aborder la configuration du DNS avec le groupe FAI pour la suite du projet.

17/10/2024


J'ai rétabli les configurations supprimées par les BUT2 la veille et j'ai préparé un serveur web fonctionnel. De plus, je me suis renseigné avec de la documentation afin de mettre en place le firewall stormshield.

14/11/2024
Gros problème dhcp rencontré cette semaine, fonctionne une fois sur 5 ou parfois il fonctionne correctement puis arrête de fonctionner, nous avons même réussi plusieurs fois à directement prendre une ip dhcp sur le pc physique. En analysant les logs et les trames dhcp sur le port 67 et 68, le serveur dhcp reçoit la demande et envoie une ip mais le client ne le reçoit pas, ce matin le serveur ne recevait même pas la demande puis l'après-midi il le recevait. J'ai changé de routeur pour savoir si il y a avait un blocage à cause du ip helper address, malgré le fait que j'ai mis en place une configuration minimal et réinitialisé le routeur et switch et analysé les trames dhcp, changer les câbles, je ne sais pas d'où vient le problème précisement, même si je pense que ca doit venir du ip helper address qui ne fait pas toujours son trvail par conséquent, on utilise désormais un dhcp relay sur debian, celà à l'air de beaucoup mieu fonctionner, même si defois il n'arrive pas a ping le serveur dhcp puis réussi à le ping tout seul quand on re test. J'ai réussi à l'installer sans interface interactive dans vagrant directement avec un script bash, car dans le vagrant le mode non interactive ne fonctionne pas pour l'installation de isc-dhcp-relay et tourne en boucle lors du vagrant up.

25/11/2024

J'ai réussi à réparer le dhcp en mettant des mac personnalisé pour chaque vm, de plus j'ai mis en place le nfs et réussi à ajouter des routes persistantes, car lors du montage des partitions pendant le démarrage, les clients n'arrivent pas à monter leurs partitions sans avoir leurs routes. On ne peut pas mettre les routes persistantes dans le provision de vagrant car lors du rédémarrage des interfaces vagrant ne voudra pas, il faut le faire en script et l'éxécuter dans chaque client.

26/11/2024

J'ai mis en place la connectivité entre notre réseau privé et notre public ainsi qu'installer et testé le proxy

27/11/2024

j'ai mis en place le firewall stormshield, fait des test dns, le firewall bloque tout de base, il faudra ajouter les permissions. J'ai refait des scripts de route persistante et j'ai mis le proxy que j'ai fait dans le bon réseau. Il sera nécéssaire de rajouter demain les bonnes règles dans le firewall.

11/12/2024

J'ai remis en place une nouvelle fois le firewall stormshield, j'ai configuré des règle de filtrage pour permettre au pc client production de pouvoir communiquer avec le réseau public, je sais que les règles fonctionne, car je peux ping ou non l'adresse out du routeur, selon les règles que je choisis. Cependant, je ne pas ping les pc dans le public, je pense que cela vient juste d'un petit problème d'ip route dans le routeur que j'ai du modifier lors de l'installation du firewall.
J'ai aussi fait le nfs v4 et le proxy .

6/1/2025

Nouvelles règles firewall, préparation des stations de travails, tests pour voir si tout fonctionne.

7/1/2025

serveur mail mise en place mais encore des problème étrange qui arrivent très très régulièrement sur notre baie, le serveur mail est sur le réseau public, j'ai fait une translation de port pour y avoir accès, cela fonctionne, puis cela ne fonctionne plus, lorsque je fais telnet 10.64.0.1 389 directement sur le pc public douglas08, je vois que la translation fonctionne mais il ne trouve pas la base ldap, alors qu'elle est bel et bien en train d'écouter sur le port 389, après avoir cherché plusieurs heures, pour comprendre pourquoi cela ne fonctionné pas, j'éteins la baie, car je sais que nous avons très régulièrement des problèmes lié au adresses mac comme nos problèmes dhcp, en rallumant la baie cela fonctionne très bien. Ces problème de mac nous font perdre un temps incroyable, car nous pensons que les problèmes viennent de nous, nous avons ces problèmes depuis septembre. Nous avons réussi a les règlé plus ou moins sur le réseau privé en mettant des adresses mac fixe, j'ai fais pareil sur le réseau public, mais cela fait moins effet.

8/1/2025

Le serveur web et mail ne pouvaient plus être ping depuis le réseau privé, pendant 30 minutes, depuis le serveur web et dns valentin ainsi que moi avons ping notre ip public en 10.64.0.1, puis depuis notre privé, nous avons réussi à ping ces deux machines du réseau public en 10.64.4 et 10.64.0.3. Nous rencontrons énormément de problèmes de ce type, comme si il y avait de mauvaises résolutions ARP.
Monsieur Beaufils a reglé le problème du ssh vagrant qui ne fonctionnait pas sur douglas07, la cause étant que certaines ligne n'était pas indenté dans la configuration des fichiers ssh, dont nous n'avions pas accès (pas root sur les douglas). La clef ssh ne connaissant pas le protocole de chiffrement à utilisé.

9/1/2025

Aujourd'hui? je suis revenu sur le serveur dns1 et dns2, pour les configurer, car ils présentent des erreurs, notamment le fait que dns2 n'arrive pas à résoudre les requêtes dns des zones des autres groupes de la SAE.

10/1/2025

J'ai essayé de résoudre le problème du dns2 qui ne pas résoudre les requêtes dns par récursion, alors que le dns1 réussi à le faire.

20/1/2025

J'ai remis la baie dans son état normal, car les câbles ont étaient interverti de place. J'ai mis en place le dns2, il fonctionne bien, arrive a trouver les enregistrement dns des autres groupes de la sae et prends le relais du dns1 lorsqu'il est éteint, j'ai mis en place le serveur mail et réaliser des tests d'envoi et de réception avec les autres groupes, j'ai écrit de la documentation et fait beaucoup de test où j'éteignais toute l'infra et la rallumé pour voir si elle était stable, et elle est bel et bien stable.

21/1/2025

J'ai réalisé des tests finaux pour une fois de plus voir si l'infra était stable, j'ai réalisé tout les tests x4 en l'éteignant et la rallumant, aucun problème à signaler, l'infra est bel et bien stable et j'ai rédigé de la documentation, notamment celle du serveur mail.




