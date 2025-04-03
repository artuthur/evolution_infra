# Procédure d'installation de SpamAssassin pour notre serveur web

## Objectif
Installer et configurer **SpamAssassin** pour filtrer les spams sur un serveur mail utilisant **Postfix**.

## Références
Tutoriel : [https://www.pycolore.fr/debian/serveur-mail/spamassassin.html](https://www.pycolore.fr/debian/serveur-mail/spamassassin.html)

## Étape 1 : Installation des paquets nécessaires

### 1.1 Mettre à jour le système
Avant toute installation, assurez-vous que le système est à jour.

```bash
apt update && apt upgrade -y
```

### 1.2 Installer SpamAssassin
Installez le paquet **spamassassin** et ses dépendances.

```bash
apt install spamassassin
```

### 1.3 Ajouter un utilisateur pour SpamAssassin
Créez un utilisateur dédié pour exécuter SpamAssassin de manière sécurisée.

```bash
adduser --disabled-login --home /var/spamd spamd
```

## Étape 2 : Activer et configurer SpamAssassin

### 2.1 Modifier le fichier de configuration par défaut
Ouvrez le fichier `/etc/default/spamassassin` pour activer SpamAssassin et permettre son exécution régulière via CRON.

```bash
nano /etc/default/spamassassin
```

Dans ce fichier, ajoutez la ligne suivante :

```conf
CRON=1
```

Enregistrez les modifications et quittez.

### 2.2 Redémarrer le service SpamAssassin
Après modification, redémarrez le service SpamAssassin pour appliquer les changements.

```bash
systemctl restart spamd.service
```

## Étape 3 : Configurer Postfix pour utiliser SpamAssassin

### 3.1 Modifier le fichier `master.cf`
Ouvrez le fichier de configuration Postfix `master.cf`.

```bash
nano /etc/postfix/master.cf
```

Dans ce fichier, trouvez la ligne suivante :

```conf
smtp      inet  n       -       -       -       -       smtpd
```

Remplacez-la par cette version pour activer le filtre de contenu avec SpamAssassin :

```conf
smtp      inet  n       -       -       -       -       smtpd   -o content_filter=spamassassin
```

### 3.2 Ajouter SpamAssassin à la fin du fichier
Ajoutez le bloc suivant à la fin du fichier `master.cf` pour que Postfix utilise SpamAssassin comme filtre :

```conf
spamassassin unix -     n       n       -       -       pipe
  user=spamd argv=/usr/bin/spamc -f -e /usr/sbin/sendmail -oi -f ${sender} ${recipient}
```

Enregistrez les modifications et quittez.

### 3.3 Redémarrer Postfix
Rechargez la configuration de Postfix pour appliquer les modifications.

```bash
postfix reload
```