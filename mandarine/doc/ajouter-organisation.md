# Procédure d'ajout d'une nouvelle organisation

## Pré-requis

Avant de commencer, assurez-vous de :  
- Vérifier les [plages d'adresses disponibles](./archi.md).  
- Collecter toutes les informations spécifiques à l'organisation (nom, plage IP, serveurs DNS éventuels, etc.).

## Configuration réseau et matériel  

### Routeurs et switchs  

Ajoutez un nouveau réseau pour la nouvelle organisation en suivant les configurations détaillées des routeurs et switchs :  
- [Configuration du routeur régional](./configuration/region/region-r1.conf)  
- [Configuration du switch régional](./configuration/region/region-s2.conf)  

## Configuration DNS  

### Ajout des résolutions dans le DNS  

Si l'organisation met en place un serveur DNS, les étapes suivantes doivent être suivies.  

#### 1. Modification du fichier `db.iut`  

Ajoutez les enregistrements DNS requis pour l'organisation dans le fichier `/etc/bind/db.iut`. Voici un exemple :  

```conf
; Serveurs DNS pour le domaine iut
@       IN      NS      xxx.iut.    ; Serveur secondaire pour Mandarine

; Enregistrements A pour les serveurs DNS
xxx      IN      A      10.xx.yy.zz          ;

; Délégation pour les sous-domaines
xxx.iut.    IN  NS      ns1.xxx.iut.  ; 

; Enregistrements A pour les serveurs DNS des sous-domaines
ns1.xxx.iut.    IN  A  10.xx.yy.zz     ; Serveur DNS principal
```  

#### 2. Création du fichier de zone PTR  

Créez un fichier de zone PTR nommé `db.10.xx-ptr` et configurez-le comme suit :  

```conf
;
; Zone PTR file
;
$TTL 604800
@       IN      SOA     ns1.iut. admin.iut. (
                              2024112503    ; Numéro de série
                              604800        ; Rafraîchissement
                              86400         ; Réessai
                              2419200       ; Expiration
                              604800 )      ; Cache négatif TTL

@        IN      NS      ns1.iut.
@        IN      NS      ns2.iut.

zz       IN      PTR     ns1.xxx.iut.
```  

#### 3. Modification du fichier `named.conf.local`  

Ajoutez une nouvelle zone dans le fichier `/etc/bind/named.conf.local` :  

```conf
zone "yy.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.yy-ptr";
    allow-transfer { 10.0.0.2; 10.0.0.20; 10.64.0.2; 10.64.0.5; 10.128.0.2; 10.128.0.5; 10.192.0.2; 10.192.0.6; 10.192.0.50; 10.xx.yy.zz; };
    also-notify { 10.0.0.2; 10.0.0.20; 10.64.0.2; 10.64.0.5; 10.128.0.2; 10.128.0.5; 10.192.0.2; 10.192.0.6; 10.192.0.50; 10.xx.yy.zz; };
};
```  

## Configuration du serveur mail  

### Mise à jour du fichier `main.cf`  

Pour ajouter le domaine de l'organisation au relais de messagerie, modifiez le fichier `/etc/postfix/main.cf`. Trouvez la ligne suivante :  

```conf
relay_domains = $mydestination...
```  

Ajoutez le nouveau domaine :  

```conf
relay_domains = $mydestination (...) xxx.iut
```  

Redémarrez le service Postfix pour appliquer les modifications :  

```bash
systemctl restart postfix.service
```  

## Configuration des serveurs DNS de l'organisation  

Chaque organisation devra configurer son serveur DNS pour utiliser les serveurs maîtres comme forwarders. Modifiez le fichier `/etc/bind/named.conf.options` sur le DNS local de l'organisation :  

```conf
options {
        directory "/var/cache/bind";
        
        dnssec-validation auto;

        listen-on-v6 { any; };

        forwarders {
                10.192.0.5;  # Serveur DNS maître
                10.192.0.50; # Serveur DNS secondaire
        };

        recursion yes;
};
```  