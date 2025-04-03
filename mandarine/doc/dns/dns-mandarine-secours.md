# Documentation sur le DNS Mandarine de Secours

## Utilisation du `Vagrantfile`

Un `Vagrantfile` a été créé pour générer une machine virtuelle Debian sur l'ordinateur physique `Douglas01`. Cette machine virtuelle, nommée `srv-dns-mandarine-secours`, joue le rôle de **serveur DNS secondaire** pour assurer la redondance et la haute disponibilité.

- **Adresse IP attribuée** : `10.192.0.6` (réseau public configuré).
- **Passerelle** : L'ordinateur hôte `Douglas01` agit comme un bridge entre la machine physique et la machine virtuelle.

Après la création de la machine virtuelle, un script est exécuté automatiquement pour installer et configurer Bind9, ainsi que les outils nécessaires.

- **Fichier Vagrant** : [srv-dns-mandarine-secours](../../bin/dns-mandarine-secours/Vagrantfile)

## Explication du Script

- **Script utilisé** : [dns-mandarine-sec.sh](../../bin/dns-mandarine-secours/dns-mand-sec.sh)

### Mise en place des routes

Des routes spécifiques sont ajoutées pour assurer la communication entre les réseaux. Voici les commandes utilisées :

```bash
ip r add 10.0.0.0/8 via 10.192.0.254 dev eth1
ip r add 192.168.56.0/22 via 10.192.0.254 dev eth1
```

- **Réseau public** : La route `10.0.0.0/8` englobe tout le réseau public configuré.
- **Réseau privé** : La route `192.168.56.0/22` concerne le réseau privé utilisé localement.
- **Passerelle** : L'adresse IP `10.192.0.254` est définie comme routeur/gateway pour les communications externes.

### Modification du fichier `resolv.conf`

Pour garantir une résolution DNS correcte, le fichier `/etc/resolv.conf` est configuré pour pointer vers le DNS maître et le DNS de secours :

```bash
cat << TUTU > /etc/resolv.conf
nameserver 10.192.0.2
nameserver 10.192.0.6
TUTU
```

- **10.192.0.2** : Serveur DNS maître.
- **10.192.0.6** : Serveur DNS secondaire (celui configuré ici).

### Installation des outils DNS

Les paquets requis pour le serveur DNS sont installés avec :

```bash
apt install bind9 bind9utils bind9-doc -y
```

## Configuration du DNS Mandarine de Secours

### Fichier `named.conf.local`

Ce fichier est configuré pour déclarer les zones secondaires (esclaves). Ces zones reçoivent leurs données depuis le serveur DNS maître.

```conf
zone "mandarine.iut" {
    type slave;                            // Zone secondaire
    file "/var/cache/bind/db.mandarine.iut"; // Fichier local de sauvegarde
    masters { 10.192.0.2; };               // Adresse IP du serveur DNS maître
};

zone "0.192.10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.0.192.10-ptr"; // Fichier de sauvegarde pour la zone inverse
    masters { 10.192.0.2; };               // Adresse IP du DNS maître
};
```

- **Zone directe (`mandarine.iut`)** : Contient les enregistrements standards (A, CNAME, MX, etc.).
- **Zone inverse (`0.192.10.in-addr.arpa`)** : Utilisée pour la résolution inverse (IP → nom de domaine).

### Fichier `named.conf.options`

Ce fichier configure les options globales de Bind9. Voici une version adaptée pour ce serveur DNS secondaire :

```conf
options {
    directory "/var/cache/bind";          // Répertoire utilisé pour les fichiers de cache et zones locales
    
    dnssec-validation auto;              // Validation DNSSEC automatique pour plus de sécurité

    listen-on-v6 { any; };               // Accepter les connexions sur toutes les interfaces IPv6

    forwarders {
        10.192.0.5; 10.192.0.50;         // Serveurs maître utilisés pour les requêtes externes
    };

    recursion yes;                       // Activer la récursivité pour résoudre les noms externes

    allow-query {
        192.168.57.0/24;                 // Réseau autorisé
        130.130.0.0/16;                  // Réseau autorisé
        192.168.58.0/24;                 // Réseau autorisé
        10.0.0.0/8;                      // Réseau public complet
    };

    allow-query-cache {
        192.168.57.0/24;
        130.130.0.0/16;
        192.168.58.0/24;
        10.0.0.0/8;
    };
};
```

## Vérification et Redémarrage

### Vérifications

Avant de redémarrer Bind9, il est essentiel de vérifier que la configuration est valide :

```bash
named-checkconf
```

### Redémarrage du Service DNS

Une fois la configuration validée, redémarrez le service DNS :

```bash
systemctl restart bind9
```