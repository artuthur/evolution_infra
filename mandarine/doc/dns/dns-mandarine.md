# Documentation sur le DNS Mandarine

## Utilisation du `Vagrantfile`

Un `Vagrantfile` a été créé pour générer une machine virtuelle Debian sur l'ordinateur physique `Douglas01`. Cette machine virtuelle porte le nom de `srv-dns-mandarine`.

- **Adresse IP** : La machine se voit attribuer l'adresse IP `10.192.0.2`, appartenant au réseau public configuré.
- **Passerelle** : L'ordinateur physique `Douglas01` agit comme passerelle (bridge) entre l'hôte et la machine virtuelle.

Un script est ensuite exécuté pour installer et configurer les outils nécessaires à la mise en place du serveur DNS.

Fichier `Vagrantfile` : [srv-dns-mandarine](../../bin/dns-mandarine/Vagrantfile)

## Explication du script

Script utilisé : [dns-mand.sh](../../bin/dns-mandarine/dns-mand.sh)

### Mise en place des routes

Les routes sont configurées pour permettre la communication avec l'extérieur à l'aide des commandes suivantes :

```bash
ip r add 10.0.0.0/8 via 10.192.0.254 dev eth1
ip r add 192.168.56.0/22 via 10.192.0.254 dev eth1
```

- **Réseau public** : La route vers `10.0.0.0/8` couvre l'étendue du réseau public.
- **Réseau privé** : La route vers `192.168.56.0/22` couvre l'étendue du réseau privé.
- **Passerelle** : La passerelle `10.192.0.254` correspond à l'interface de notre routeur.

### Modification du `nameserver`

Les adresses des serveurs DNS locaux sont modifiées pour pointer vers notre serveur principal et un serveur de secours :

```bash
cat << EOF > /etc/resolv.conf
nameserver 10.192.0.2
nameserver 10.192.0.6
EOF
```

### Installation des outils

Les paquets nécessaires à Bind9 sont installés avec :

```bash
apt install bind9 bind9utils bind9-doc -y
```

- L'option `-y` valide automatiquement les étapes d'installation.

---

## Configuration du DNS Mandarine

### Modification du fichier `named.conf.local`

Le fichier `named.conf.local` est modifié pour définir les zones DNS suivantes :

- **Zone esclave pour le domaine `iut`** : Synchronisation automatique à partir du serveur maître.
- **Zone inverse pour le réseau `10.192.0.0/24`** : Réplication à partir du serveur maître.
- **Zone maîtresse pour `mandarine.iut`** : Gestion directe par le serveur DNS Mandarine.
- **Zone maîtresse inverse pour `mandarine.iut`** : Résolution inverse des adresses IP.

Contenu du fichier :

```conf
zone "iut" {
    type slave;
    file "/var/cache/bind/db.iut";
    masters { 10.192.0.5; };  # Serveur maître .iut
};

# Zone inverse pour 10.192.0.0/24 (sous-réseau de mandarine)
zone "10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.10-ptr";
    masters { 10.192.0.5; };
};

# Zone maîtresse pour le sous-domaine mandarine.iut
zone "mandarine.iut" {
    type master;
    file "/etc/bind/db.mandarine.iut";  # Fichier contenant les enregistrements DNS locaux
};

# Zone maîtresse inverse pour le sous-domaine mandarine.iut
zone "0.192.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.0.192.10-ptr";
};
```

### Modification du fichier `named.conf.options`

Le fichier `named.conf.options` contient les options suivantes :

```conf
options {
        directory "/var/cache/bind";
        
        dnssec-validation auto;

        listen-on-v6 { any; };

        forwarders {
                10.192.0.5;  # Adresse du maître pour la résolution externe
                10.192.0.50;
        };

        recursion yes;

	allow-query-cache { 192.168.57.0/24; 130.130.0.0/16; 192.168.58.0/24; 10.0.0.0/8; };
	allow-query { 192.168.57.0/24; 130.130.0.0/16; 192.168.58.0/24; 10.0.0.0/8; };
};
```

### Préparation du fichier `db.mandarine.iut`

Ce fichier contient les enregistrements DNS pour la zone directe du domaine `mandarine.iut`.

Exemple de contenu :

```conf
;
; Zone file for mandarine.iut
;
$TTL    604800
@       IN      SOA     mandarine.iut. admin.mandarine.iut. (
                              2023101501   ; Numéro de série (YYYYMMDDNN)
                              604800       ; Rafraîchissement (7 jours)
                              86400        ; Réessai (1 jour)
                              2419200      ; Expiration (4 semaines)
                              604800 )     ; Cache négatif TTL (1 semaine)

; Serveurs DNS pour le domaine mandarine.iut
@       IN      NS      ns1.mandarine.iut.
@       IN      NS      ns2.mandarine.iut.

; Enregistrements A pour les services de mandarine.iut
ns1.mandarine.iut.      IN      A       10.192.0.2              ; Serveur DNS
ns2.mandarine.iut.      IN      A       10.192.0.6              ;
web.mandarine.iut.      IN      A       10.192.0.3              ; Serveur web (Apache)
mail.mandarine.iut.     IN      A       10.192.0.3              ; Serveur mail
autoconfig.             IN      CNAME   mandarine.iut.          ;
mandarine.iut.          IN      TXT     "v=spf1 a mx -all"      ;

; Enregistrement MX pour la gestion des mails
@                       IN      MX      10 mail.mandarine.iut.
```

### Préparation des fichiers de zone inverse

Exemple de contenu du fichier de zone inverse :

```conf
;
; BIND reverse data file for 10.192.0.0/24
;
$TTL    604800
@       IN      SOA     mandarine.iut. admin.mandarine.iut. (
                              2023101203   ; Numéro de série (YYYYMMDDNN)
                              604800       ; Rafraîchissement (7 jours)
                              86400        ; Réessai (1 jour)
                              2419200      ; Expiration (4 semaines)
                              604800 )     ; Cache négatif TTL (1 semaine)

; Serveur DNS principal de la zone inverse
@       IN      NS      ns1.mandarine.iut.

; Résolution inverse (PTR) pour les adresses IP
2       IN      PTR     ns1.mandarine.iut.    ; Résolution inverse pour 10.192.0.2
3       IN      PTR     mail.mandarine.iut.   ; Résolution inverse pour 10.192.0.3
3       IN      PTR     web.mandarine.iut.    ; Alias pour 10.192.0.3 (serveur Web/Mail)
6       IN      PTR     ns2.mandarine.iut.    ; Résolution inverse pour 10.192.0.6
```

---

## Vérification des configurations

Une fois les fichiers configurés, vérifier leur validité :

```bash
# Vérification de la configuration principale
named-checkconf

# Vérification de la zone directe
named-checkzone mandarine.iut /etc/bind/db.mandarine.iut

# Vérification de la zone inverse
named-checkzone 0.192.10.in-addr.arpa /etc/bind/db.0.192.10-ptr
```

---

## Rechargement de la configuration DNS

Si toutes les vérifications réussissent, redémarrer Bind9 pour appliquer les modifications :

```bash
systemctl restart bind9
```