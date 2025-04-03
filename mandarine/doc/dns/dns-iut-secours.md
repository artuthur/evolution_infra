# Documentation sur le DNS IUT de Secours

## Utilisation du `Vagrantfile`

Un `Vagrantfile` a été créé pour générer une machine virtuelle Debian sur l'ordinateur physique `Douglas01`. Cette machine virtuelle, nommée `srv-dns-iut-secours`, joue le rôle de serveur DNS secondaire pour assurer la redondance et la haute disponibilité.

- **Adresse IP attribuée** : `10.192.0.50`, faisant partie du réseau public configuré.
- **Passerelle** : L'ordinateur hôte `Douglas01` agit comme un bridge entre la machine physique et la machine virtuelle.

Un script est exécuté après la création de la machine pour installer et configurer automatiquement les outils nécessaires au bon fonctionnement du serveur DNS.

- **Fichier Vagrant** : [srv-dns-iut-secours](../../bin/dns-iut-secours/Vagrantfile)

## Explication du Script

- **Script utilisé** : [dns-iut-sec.sh](../../bin/dns-iut-secours/dns-iut-sec.sh)

### Mise en place des routes

Des routes spécifiques sont configurées pour permettre la communication avec les autres réseaux et l'extérieur. Cela se fait via les commandes suivantes :

```bash
ip r add 10.0.0.0/8 via 10.192.0.254 dev eth1
ip r add 192.168.56.0/22 via 10.192.0.254 dev eth1
```

- **Réseau public** : La route `10.0.0.0/8` couvre l'ensemble du réseau public configuré.
- **Réseau privé** : La route `192.168.56.0/22` couvre l'ensemble du réseau privé.
- **Passerelle** : `10.192.0.254` correspond à l'interface routeur utilisée comme point de sortie.

### Modification du fichier `resolv.conf`

Pour garantir une résolution DNS appropriée, le fichier `/etc/resolv.conf` est mis à jour avec les adresses IP des serveurs DNS maître et de secours :

```bash
cat << TUTU > /etc/resolv.conf
nameserver 10.192.0.5
nameserver 10.192.0.50
TUTU
```

### Installation des outils DNS

Les paquets nécessaires pour le serveur DNS sont installés à l'aide de la commande suivante :

```bash
apt install bind9 bind9utils bind9-doc -y
```

## Configuration du DNS IUT de Secours

### Fichier `named.conf.local`

Le fichier `named.conf.local` est configuré pour définir les zones DNS du serveur secondaire. Ces zones sont synchronisées automatiquement avec le serveur maître.

```conf
zone "iut" {
    type slave;                           // Indique qu'il s'agit d'une zone secondaire
    masters { 10.192.0.5; };              // Spécifie l'adresse IP du serveur maître
    file "/var/cache/bind/db.iut";        // Fichier local de sauvegarde pour la zone
};

zone "5.0.192.10.in-addr.arpa" {
    type slave;
    masters { 10.192.0.5; };              // Maître pour la zone inverse
    file "/var/cache/bind/db.10.0-ptr";   // Fichier de sauvegarde pour la zone inverse
};
```

- **Zone directe** : La zone `iut` contient les enregistrements DNS normaux (A, NS, etc.).
- **Zone inverse** : La zone `5.0.192.10.in-addr.arpa` contient les enregistrements PTR pour la résolution inverse des adresses IP.

### Fichier `named.conf.options`

Le fichier `named.conf.options` configure les options globales du serveur DNS. Voici le contenu proposé :

```conf
options {
    directory "/var/cache/bind";        // Répertoire de cache utilisé par Bind9

    dnssec-validation auto;            // Active la validation DNSSEC automatique

    recursion yes;                     // Autorise la récursivité pour résoudre les noms externes

    allow-recursion { any; };          // Permet la récursivité pour toutes les adresses (peut être restreint)

    listen-on-v6 { any; };             // Écoute sur toutes les interfaces IPv6
    listen-on { any; };                // Écoute sur toutes les interfaces IPv4
};
```

## Vérification et Redémarrage

### Vérifications

Avant de redémarrer le service, il est important de vérifier que la configuration ne contient pas d'erreurs :

```bash
# Vérifie la syntaxe de la configuration principale
named-checkconf
```

### Redémarrage du Service DNS

Si aucune erreur n'est détectée, redémarrez le service Bind9 pour appliquer les modifications :

```bash
systemctl restart bind9
```