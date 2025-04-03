---
title: Mise en place d'un second serveur DNS
---

## Objectif

L'objectif de ce guide est de configurer un serveur DNS secondaire avec **Bind9** afin qu'il prenne le relais du serveur DNS principal en cas de panne ou autre indisponibilité. Le serveur secondaire récupère les zones DNS depuis le serveur principal et répond aux requêtes DNS.

### Prérequis

Avant de commencer, assurez-vous que :
- Vous avez accès à un serveur où vous pouvez installer Bind9.
- Vous avez l'IP du serveur DNS principal.
- Le réseau est configuré correctement pour permettre la communication entre les serveurs DNS principal et secondaire.

---

## Étapes de mise en place

### **Installer le service Bind9**

Pour installer Bind9 sur le serveur DNS secondaire, mettez à jour la liste des paquets et installez Bind9 à l'aide de la commande suivante :

```bash
sudo apt-get update
sudo apt-get install -qy bind9
```

### **Ajouter une route statique**

Si nécessaire, ajoutez une route statique pour que le serveur DNS secondaire puisse communiquer avec le serveur DNS principal via le réseau approprié.

```bash
sudo ip r a 10.0.0.0/8 dev eth1
```

Cela permet au serveur secondaire de se connecter correctement au réseau du serveur principal.

### **Configurer les zones DNS**

Vous devez maintenant configurer les zones DNS qui seront répliquées par le serveur secondaire depuis le serveur principal.

- Ouvrez le fichier de configuration des zones `/etc/bind/named.conf.local` :
  
  ```bash
  sudo nano /etc/bind/named.conf.local
  ```

- Ajoutez les zones DNS en tant qu'esclaves :

  ```bash
  zone "amerique.iut" {
      type slave;
      file "/var/cache/bind/db.amerique.iut";
      masters { 10.64.0.2; }; # Adresse IP du serveur maître
  };
  
  zone "0.64.10.in-addr.arpa" {
      type slave;
      file "/var/cache/bind/db.0.10.64";
      masters { 10.64.0.2; }; # Adresse IP du serveur maître
  };
  ```

  - **`type slave`** : Indique que le serveur est un esclave pour ces zones.
  - **`masters { 10.64.0.2; }`** : Spécifie l'adresse IP du serveur principal qui fournira les mises à jour de la zone.

### **Configurer les options DNS**

Les options DNS sont spécifiées dans le fichier `/etc/bind/named.conf.options`. Cela permet de définir des paramètres importants pour le fonctionnement du serveur DNS secondaire.

- Ouvrez le fichier de configuration des options DNS :

  ```bash
  sudo nano /etc/bind/named.conf.options
  ```

- Ajoutez les paramètres suivants :

  ```bash
  options {
      directory "/var/cache/bind";
  
      recursion yes;
      allow-query { any; };
      allow-recursion { any; };
      dnssec-validation no;
      forwarders {
          10.192.0.5; # Adresse du serveur DNS principal
      };
  
      listen-on { any; };
      listen-on-v6 { none; };
  };
  ```

  - **`recursion yes;`** : Permet la récursion pour toutes les requêtes DNS.
  - **`allow-query { any; };`** : Permet à n'importe quel client de poser une requête DNS.
  - **`forwarders { 10.192.0.5; };`** : Dirige les requêtes non résolues vers un serveur DNS externe.
  - **`listen-on-v6 { none; };`** : Désactive l'écoute des requêtes IPv6.

### **Configurer le démarrage du service Bind9 avec IPv4 uniquement**

Le serveur DNS secondaire doit utiliser uniquement IPv4. Pour ce faire, modifiez la configuration du service `bind9` :

- Ouvrez le fichier de service `named.service` :

  ```bash
  sudo nano /lib/systemd/system/named.service
  ```

- Ajoutez l'option `-4` à la ligne `ExecStart` :

  ```bash
  ExecStart=/usr/sbin/named -f $OPTIONS -4
  ```

Cela forcera le serveur à utiliser IPv4 uniquement.

### **Recharger la configuration de systemd et redémarrer Bind9**

Une fois les modifications effectuées, rechargez la configuration de `systemd` pour appliquer les modifications :

```bash
sudo systemctl daemon-reload
```

Redémarrez ensuite le service `bind9` pour appliquer la nouvelle configuration :

```bash
sudo systemctl restart bind9
```

### **Configurer le serveur DNS local**

Enfin, configurez le fichier `resolv.conf` pour que le serveur DNS secondaire utilise lui-même comme serveur de noms. Cela garantit que les requêtes locales sont résolues par le serveur DNS lui-même.

- Ouvrez et modifiez le fichier `resolv.conf` :

  ```bash
  sudo nano /etc/resolv.conf
  ```

- Ajoutez la ligne suivante :

  ```bash
  nameserver 127.0.0.1
  ```

Cela configure le serveur pour utiliser son propre serveur DNS local comme résolveur.

---

## Test

### **Vérification du service Bind9**

Vérifiez que le service `bind9` est actif et fonctionne correctement :

```bash
sudo systemctl status bind9
```

### **Test de la résolution DNS**

Après avoir désactivé le serveur primaire DNS, utilisez `dig` pour tester la résolution DNS sur le serveur secondaire :

```bash
dig @127.0.0.1 amerique.iut
```

Cela doit renvoyer une réponse valide indiquant que le serveur DNS secondaire résout correctement les noms.

### **Vérification de la zone DNS répliquée**

Pour tester si le serveur secondaire récupère correctement la zone du serveur principal, utilisez `dig` pour interroger une zone de type PTR :

```bash
dig @127.0.0.1 0.64.10.in-addr.arpa PTR
```

Cela devrait retourner une réponse valide pour la zone inversée.

## Retour au sommaire

- [Retourner au sommaire](../../README.md#documentations---liens-rapide)
