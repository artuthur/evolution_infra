## documentation pour configuration du client ldap

tout d'abord il faut installer les paquets:

`````sh
sudo apt-get install -y ldap-utils libnss-ldap libpam-ldap nscd

`````

une fenetre s'affiche sur l'ecran il faut d'abord mettre ***l'address ip du server ldap*** et ensuite ***la base ldap*** utilise **exemple:(dc=amerique,dc=iut)**

avant tout chose verifier bien que votre machine communique bien avec votre server ldap

````sh
ping 192.168.65.3
````

verifier bien la configuration dans **/etc/nslcd.conf**

````bash

uri ldap://192.168.65.3

base dc=amerique,dc=iut

binddn cn=admin,dc=amerique,dc=iut

bindpw password_admin

````

verifier que le service est en **running** et que les logs n'affiche pas d'erreur

`````bash
sudo systemctl status nscd.service
`````

modifier le file **/etc/nsswitch.conf**

il faut que les 3 premiere ligne du fichier soit representer comme ci dessou: 

``````bash
passwd:     file ldap
group:      file ldap
shadow:     file ldap
``````
pour que  le service cherche dans les fichier ldap pour te connecter en tant que l'utilisateur que tu souahaite authentifier

restart le service nslcd

`````bash
systemctl restart nslcd
`````

recherche pour verifier si on accède bien a la base : 

```bash
sudo ldapsearch -x -H ldap://192.168.65.3 -b "dc=amerique,dc=iut" "(objectClass=*)"
```

Si la connexion est établi vous devriez obtenir des résultat comme les utilisateurs ou les groupes par exemple. Néanmoins il est nécessaire de **mettre à jour le cache NSS** via la commande ci-dessous : 

```bash
sudo nscd -i group
```

Ceci est notamment utile lorsque un utilisateur LDAP a été ajouté récemment.

tu peux tester via la commande suivante:

`````bash
sudo getent passwd jean.dupont
`````
si tu as en sortie de la commande:

`````bash 
jean.dupont:x:1001:2001:Jean dupond:/home/jean.dupont:bin/bash
`````

cela veut dire que le client arrive a chercher ver le server ldap

donc vous pouver vous connecter en tant que jean.dupont 

`````bash
su - jean.dupont
`````

sauf que maintenant vous pouvez remarquer que vous n'est pas dans le bon repertoire 


ce qui faut faire est simple aller dans le fichier /etc/pam.d/common-session et rajouter la ligne ci dessous:


`````bash
session required pam_mkhomedir.so skel=/etc/skel umask=0022
````` 

redemarrer le service nslcd


`````` bash
systemctl restart nslcd
``````

enfin reconnecter vous a votre utilsateur 

`````bash
su - jean.dupont
`````

maintenant quand vous faite la commande **pwd** vous serez dans le bon repertoire

## Troubleshooting

Lors de notre mise en place, nous avons été confronté à des problèmes réseaux indépendant de notre volonté de ce fait les clients n'arrivaient plus à contacter le serveur LDAP qui pourtant lui était fonctionnel. Pour palier à ça il faut redémarrer le networking :

```bash
sudo systemctl restart networking
```

## Retour au sommaire

- [Retourner au sommaire](../../README.md#documentations---liens-rapide)