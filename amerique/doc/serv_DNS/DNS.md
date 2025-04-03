---
title: Mise en place du service DNS
---

# Mise en place du service DNS

Cette documentation décrit la mise en place d'un serveur DNS maître avec `bind9` pour la gestion des zones directe et inverse, dans le cadre de notre infrastructure réseau pour le domaine `amerique.iut`.

## Objectif

L'objectif de ce serveur maître DNS est de fournir une résolution de noms pour le domaine `amerique.iut` et de gérer une zone inverse pour le réseau `10.64.0.0/24`. Ce service permettra la résolution des adresses IP vers des noms de domaine et l'automatisation de la configuration via Vagrant.

## Configuration de la machine DNS

### Vagrantfile

Voici le bloc de configuration du serveur DNS dans le fichier `Vagrantfile`. On crée une machine virtuelle nommée `dns` avec une IP fixe `10.64.0.2`, et utilise comme en cours `bind9` comme service DNS :

```ruby
Vagrant.configure("2") do |config|

    config.vm.box = "debian/bookworm64"
    ## Serveur DNS autorité amerique.iut
    config.vm.define "dns" do |dns|
        dns.vm.hostname = "dns"
        dns.vm.network "public_network", ip: "10.64.0.2", bridge: "enp3s0"
        dns.vm.provision "file", source: "../../ext/dns", destination: "/home/vagrant/dns"
        dns.vm.provision "shell", path: "provision_dns.sh"
    end
end  
```

## Configuration des zones DNS

### Fichier de zone directe : `db.amerique.iut`

Le fichier de zone directe `/etc/bind/zones/db.amerique.iut` définit les enregistrements DNS pour le domaine `amerique.iut`. Voici sa configuration :

```conf
$TTL 604800
@       IN      SOA     ns1.amerique.iut. admin.amerique.iut. (
            2023101401 ; Serial (à mettre à jour à chaque modification)
            604800     ; Refresh
            86400      ; Retry
            2419200    ; Expire
            604800 )   ; Minimum TTL

@       IN      NS      ns1.amerique.iut.
@       IN      NS      ns2.amerique.iut.
ns1     IN      A       10.64.0.2
ns2     IN      A       10.64.0.5

@       IN      A       10.64.0.2
mail    IN      A       10.64.0.3
web     IN      A       10.64.0.4

@       IN      MX 10   mail.amerique.iut.
```

- **SOA** : Déclare le serveur de noms principal `ns1.amerique.iut` et l'email de l'administrateur `admin.amerique.iut`.
- **NS** : Déclare `ns1.amerique.iut` comme serveur de noms de cette zone.
- **Enregistrements A** : Définit les adresses IP des hôtes `ns1`, `mail`, et `web` du domaine `amerique.iut`.

### Fichier de zone inverse : `db.10.64`

Le fichier `/etc/bind/zones/db.10.64` est utilisé pour la résolution inverse, permettant de traduire les adresses IP en noms de domaine pour le réseau `10.64.0.0/24`.

```conf
$TTL 604800
@       IN      SOA     ns1.amerique.iut. admin.amerique.iut. (
            2023101401 ; Serial
            604800     ; Refresh
            86400      ; Retry
            2419200    ; Expire
            604800 )   ; Minimum TTL

@       IN      NS      ns1.amerique.iut.
@       IN      NS      ns2.amerique.iut.

2       IN      PTR     ns1.amerique.iut.
5       IN      PTR     ns2.amerique.iut.
3       IN      PTR     mail.amerique.iut.
4       IN      PTR     web.amerique.iut.
```

- **SOA** : Déclare le serveur de noms principal et l'administrateur pour cette zone.
- **NS** : Déclare `ns1.amerique.iut` comme serveur de noms pour cette zone inverse.
- **Enregistrements PTR** : Associe les adresses IP à des noms d'hôte pour `ns1`, `mail`, et `web`.

### Fichier de zones DNS local : `named.conf.local`

Le fichier `/etc/bind/named.conf.local` est utilisé pour définir les zones DNS locales. Il contient des configurations pour les zones "master" (maîtres) et "slave" (esclaves).

```local
zone "amerique.iut" {
    type master;
    file "/etc/bind/db.amerique.iut";
    allow-transfer { 10.64.0.5; }; # Adresse IP du serveur secondaire
};

zone "0.64.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.64";
    allow-transfer { 10.64.0.5; }; # Adresse IP du serveur secondaire
};

zone "iut" {
    type slave;
    file "/var/cache/bind/db.iut";
    masters { 10.192.0.5; };
};
```

### Fichier de configuration du serveur DNS : `named.conf.options`

Le fichier `/etc/bind/named.conf.options` contient les paramètres globaux et les options DNS pour le serveur BIND.

```options
options {
    directory "/var/cache/bind";  // Répertoire de travail pour les fichiers de cache de Bind

    recursion yes;               // Active la récursivité (répond aux requêtes pour des domaines non locaux)
    allow-query { any; };  
    allow-update { any; };       // Permet à n'importe quelle machine de poser des requêtes
    allow-recursion { any; }; 

    // Configuration des serveurs DNS
    forwarders {
        10.192.0.5;              // Serveur DNS vers lequel les requêtes externes sont transférées
    };

    dnssec-validation auto;      // Validation automatique des réponses DNS avec DNSSEC
    listen-on { any; };          // Le serveur écoute sur toutes les interfaces
    listen-on-v6 { none; };      // Le serveur n'écoute pas sur les interfaces IPv6
};
```

## Configuration de l'interface réseau

Le fichier `/etc/default/isc-dhcp-server` doit être configuré pour écouter sur l'interface réseau, `eth1` dans notre cas :

```bash
INTERFACESv4="eth1"
```

## Démarrage et vérification du service DNS

### Redémarrer Bind9

Pour appliquer les modifications, redémarrez le service Bind9 :

```bash
sudo systemctl restart bind9
```

### Tester la configuration DNS

Avant de tester il est important de faire attention à ce que les routes soient configurées au sein de notre machine virtuelle vagrant :

```bash
ip r a 10.0.0.0/8 dev eth1 
```

Pour tester la résolution de noms et la zone inverse, utilisez les commandes suivantes :

```bash
# Test de la résolution directe
dig @10.64.0.2 web.amerique.iut

# Test de la résolution inverse
dig -x 10.64.0.4 @10.64.0.2

# Test avec le FAI
dig @10.64.0.2 iut.
```

Une fois la commande éxecuté, nous pouvons retrouvé le résultat de celle-ci dans la section `->>HEADER<<-` de notre sortie standard et plus précisement dans la catégorie `status: <status>`. Si le status de notre commande est `NOERROR` cela signifie que le serveur a bien trouvé un ou des enregistrements pour l'argument passé au contraire si elle retourne `SRVFAIL` le serveur DNS n'a pas trouvé d'enregistrements ou celui-ci est inaccessible.  

Côté client, il est nécessaire d'ajouter l'IP de notre serveur DNS dans le fichier de configuration `resolv.conf` via la commande `echo` ou encore à la main via `nano` afin de pouvoir utiliser notre DNS.

## Retour au sommaire

- [Retourner au sommaire](../../README.md#documentations---liens-rapide)