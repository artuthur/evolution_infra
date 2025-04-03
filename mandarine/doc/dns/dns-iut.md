# Documentation sur le DNS IUT

## Utilisation du `Vagrantfile`

Le `Vagrantfile` permet de générer une machine virtuelle Debian sur l'hôte physique `Douglas01`. Cette machine virtuelle est configurée pour être le serveur DNS principal et porte le nom `srv-dns-iut`.

### Caractéristiques de la machine virtuelle
- **Adresse IP attribuée** : `10.192.0.5` (fait partie du réseau public configuré).
- **Hôte physique** : La machine physique `Douglas01` sert de passerelle (bridge) entre l'hôte et la machine virtuelle `srv-dns-iut`.
- **Script automatisé** : Un script est exécuté pour installer et configurer les outils nécessaires à la mise en place du serveur DNS.

Le `Vagrantfile` utilisé peut être consulté ici : [srv-dns-iut](../../bin/dns-iut/Vagrantfile).

## Explication du Script

Le script utilisé pour configurer le serveur DNS est disponible ici : [dns-iut.sh](../../bin/dns-iut/dns-iut.sh).

### Configuration des Routes

Les routes réseau sont configurées pour permettre la communication entre le serveur DNS et le reste du réseau. Voici les commandes utilisées :

```bash
ip r add 10.0.0.0/8 via 10.192.0.254 dev eth1
ip r add 192.168.56.0/22 via 10.192.0.254 dev eth1
```

#### Explications :
- **Route réseau public** : `10.0.0.0/8` englobe l'ensemble du réseau public.
- **Route réseau privé** : `192.168.56.0/22` couvre l'étendue du réseau privé.
- **Passerelle** : `10.192.0.254` correspond à l'interface du routeur utilisé comme passerelle.

### Modification du Nameserver

Le serveur DNS local est configuré pour pointer vers le serveur DNS IUT (`srv-dns-iut`) avec la commande suivante :

```bash
cat << EOF > /etc/resolv.conf
nameserver 10.192.0.5
EOF
```

### Installation des Outils

Les paquets nécessaires à la configuration de Bind9 sont installés via :

```bash
apt install bind9 bind9utils bind9-doc -y
```

## Configuration du DNS IUT

### Adressage des Serveurs

Les plages IP ont été standardisées pour chaque type de serveur dans le réseau public. Voici les conventions adoptées :
- **DNS** : `XX.YY.0.2`
- **Serveurs de messagerie** : `XX.YY.0.3`
- **Serveurs web** : `XX.YY.0.4`
- **Serveur DNS IUT principal** : `10.192.0.5`

### Configuration de `named.conf.local`

Le fichier `named.conf.local` est configuré pour définir les zones DNS suivantes :
1. **Zone directe** pour le domaine `iut`.
2. **Zone inverse** pour le domaine `10.in-addr.arpa`.

#### Contenu du fichier :

```conf
zone "iut" {
    type master;
    file "/etc/bind/db.iut";
    allow-transfer { 10.0.0.2; 10.0.0.20; 10.64.0.2; 10.64.0.5; 10.128.0.2; 10.128.0.5; 10.192.0.2; 10.192.0.6; 10.192.0.50; };
    also-notify { 10.0.0.2; 10.0.0.20; 10.64.0.2; 10.64.0.5; 10.128.0.2; 10.128.0.5; 10.192.0.2; 10.192.0.6; 10.192.0.50; }; 
};

zone "10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10-ptr";  # Ce fichier contiendra toutes les informations PTR
    allow-transfer { 10.0.0.2; 10.0.0.20; 10.64.0.2; 10.64.0.5; 10.128.0.2; 10.128.0.5; 10.192.0.2; 10.192.0.6; 10.192.0.50; };
    also-notify { 10.0.0.2; 10.0.0.20; 10.64.0.2; 10.64.0.5; 10.128.0.2; 10.128.0.5; 10.192.0.2; 10.192.0.6; 10.192.0.50; };
};
```

### Configuration de `named.conf.options`

Le fichier `named.conf.options` contient les paramètres globaux de configuration pour le service DNS. Il est utilisé pour définir le comportement général du serveur DNS, comme la gestion des requêtes, la récursivité et la prise en charge des adresses IPv6.

#### Contenu du fichier :

```conf
options {
    directory "/var/cache/bind";  // Répertoire de travail pour les fichiers temporaires et cache DNS

    dnssec-validation auto;       // Active la validation DNSSEC automatique

    recursion yes;                // Active la récursivité pour permettre au serveur de résoudre des requêtes externes

    allow-recursion { any; };     // Autorise toutes les adresses IP à utiliser la récursivité

    listen-on-v6 { any; };        // Écoute toutes les adresses IPv6 disponibles

    listen-on { any; };           // Écoute toutes les adresses IPv4 disponibles
};
```

### Configuration de la Zone Directe (`db.iut`)

Le fichier `db.iut` contient les enregistrements DNS pour le domaine `iut`. Voici un exemple de contenu :

```conf
;
; Zone file for iut
;
$TTL    604800         ; Time to Live par défaut
@       IN      SOA     ns1.iut. admin.iut. (
                              2024112502    ; Numéro de série (YYYYMMDDNN)
                              604800       ; Rafraîchissement (7 jours)
                              86400        ; Réessai (1 jour)
                              2419200      ; Expiration (4 semaines)
                              604800 )     ; Cache négatif TTL (1 semaine)

; Serveurs DNS pour le domaine iut
@       IN      NS      ns1.iut.          ; Serveur DNS principal
@	    IN	    NS	    ns2.iut.
@       IN      NS      afrique.iut.      ; Serveur secondaire Afrique
@       IN      NS      amerique.iut.     ; Serveur secondaire Amérique
@       IN      NS      asie.iut.         ; Serveur secondaire Asie
@       IN      NS      mandarine.iut.    ; Serveur secondaire Mandarine

; Enregistrements A pour les serveurs DNS
ns1.iut.       IN      A      10.192.0.5          ; IP du serveur DNS maître
ns2.iut.       IN      A      10.192.0.50         ;
afrique        IN      A      10.0.0.2            ; IP du DNS secondaire Afrique
amerique       IN      A      10.64.0.2           ; IP du DNS secondaire Amérique
asie           IN      A      10.128.0.2          ; IP du DNS secondaire Asie
mandarine      IN      A      10.192.0.2          ; IP du DNS secondaire Mandarine

; Délégation pour les sous-domaines
afrique.iut.    IN  NS      ns1.afrique.iut.  ; Serveur DNS principal pour afrique.iut
afrique.iut.    IN  NS      ns2.afrique.iut.  ; Serveur DNS secondaire pour afrique.iut

amerique.iut.   IN  NS      ns1.amerique.iut. ; Serveur DNS principal pour amerique.iut
amerique.iut.   IN  NS      ns2.amerique.iut. ; Serveur DNS secondaire pour amerique.iut

asie.iut.       IN  NS      ns1.asie.iut.     ; Serveur DNS principal pour asie.iut
asie.iut.       IN  NS      ns2.asie.iut.     ; Serveur DNS secondaire pour asie.iut

mandarine.iut.  IN  NS      ns1.mandarine.iut.; Serveur DNS principal pour mandarine.iut
mandarine.iut.  IN  NS      ns2.mandarine.iut.; Serveur DNS secondaire pour mandarine.iut

; Enregistrements A pour les serveurs DNS des sous-domaines
ns1.afrique.iut.    IN  A  10.0.0.2     ; Serveur DNS principal Afrique
ns2.afrique.iut.    IN  A  10.0.0.20    ; Serveur DNS secondaire Afrique

ns1.amerique.iut.   IN  A  10.64.0.2    ; Serveur DNS principal Amérique
ns2.amerique.iut.   IN  A  10.64.0.5   ; Serveur DNS secondaire Amérique

ns1.asie.iut.       IN  A  10.128.0.2   ; Serveur DNS principal Asie
ns2.asie.iut.       IN  A  10.128.0.5   ; Serveur DNS secondaire Asie

ns1.mandarine.iut.  IN  A  10.192.0.2   ; Serveur DNS principal Mandarine
ns2.mandarine.iut.  IN  A  10.192.0.6   ; Serveur DNS secondaire Mandarine

; Optionnel : enregistrement pour le domaine iut lui-même
@          IN      A      10.192.0.5          ; Le domaine iut pointe vers ns1.iut
```

### Configuration de la Zone Inverse (`db.10-ptr`)

Le fichier `db.10-ptr` définit les enregistrements PTR pour la zone inverse. Exemple :

```conf
;
; Zone PTR file for iut
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

2.0.0       IN      PTR     ns1.afrique.iut.
20.0.0      IN      PTR     ns2.afrique.iut.
2.0.64      IN      PTR     ns1.amerique.iut.
5.0.64      IN      PTR     ns2.amerique.iut.
2.0.128     IN      PTR     ns1.asie.iut.
5.0.128     IN      PTR     ns2.asie.iut.
2.0.192     IN      PTR     ns1.mandarine.iut.
6.0.192     IN      PTR     ns2.mandarine.iut.
5.0.192     IN      PTR     ns2.iut.
50.0.192    IN      PTR     ns2.iut.
```

## Vérification et Redémarrage

### Vérifications
Après la configuration, les fichiers doivent être vérifiés pour éviter les erreurs :

```bash
# Vérifie la syntaxe de la configuration principale
named-checkconf

# Vérifie la zone directe
named-checkzone iut /etc/bind/db.iut

# Vérifie la zone inverse
named-checkzone 10.in-addr.arpa /etc/bind/db.10-ptr
```

### Redémarrage du Service DNS

Si aucune erreur n'est détectée, redémarrez Bind9 pour appliquer les modifications :

```bash
systemctl restart bind9
```