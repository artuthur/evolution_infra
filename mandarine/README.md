# Équipe MANDARINE (FAI)

## Introduction
L'équipe Mandarine est composée des membres suivants :
- **Halim BENIA LATRECHE**
- **Adham BERRAKANE**
- **Arthur KELLER**
- **Gabriel ROBAT**

---

## Le Projet 

### Tâches éxécutées : 

#### Halim BENIA-LATECHE

- Mise en Place de l'infrastructure réseau 
- DHCP
- Firewall 
- Mail
- Essai VPN 
- Documentations 
- Aide générale

#### Adham BERRAKANE

- Mise en Place de l'infrastructure réseau 
- Serveur NFS 
- Serveur LDAP
- client NFS
- client LDAP
- Script ldap (create/modif/suppr)
- Serveur Backup 
- Automatisation du Déploiement
- Documentations 

#### Arthur KELLER

- Mise en Place de l'infrastructure réseau 
- DNS iut
- DNS mandarine
- DNS iut secours
- DNS mandarine secours
- Mail
- Web
- Spamassassin
- Firewall
- DHCP
- Script de provision des machines automatisées
- Schéma réseau publique et de notre infrastructures
- Documentations
- Stations de travail
- Aide générale

#### Gabriel ROBAT

- Mise en Place de l'infrastructure réseau 
- Premiet jet LDAP
- DHCP
- Firewall
- Essai Kerberos 
- Documentations 
- Aide générale

--- 

## Les schémas

### Schéma réseau publique
```mermaid
flowchart TD
    %% Région Mandarine
    subgraph RegionMandarine [Région Mandarine]
        A[Routeur 1 Mandarine 
        VLAN 10: 10.0.0.254 
        VLAN 20: 10.64.0.254 
        VLAN 30: 10.128.0.254 
        VLAN 40: 10.192.0.254]
        B[Switch 1 Mandarine\nVLAN 10, 20, 30, 40]
        A -->|10.0.0.0/16| B
        A -->|10.64.0.0/16| B
        A -->|10.128.0.0/16| B
        A -->|10.192.0.0/16| B
    end

    %% Région Afrique
    subgraph RegionAfrique [Région Afrique]
        C[Switch 2 Afrique
        VLAN 10]
        G[Routeur 1 Afrique
        VLAN 10: 10.0.0.1]
        C -->|10.0.0.0/16| G
    end

    %% Région Amérique
    subgraph RegionAmerique [Région Amérique]
        D[Switch 2 Amérique
        VLAN 20]
        H[Routeur 1 Amérique
        VLAN 20: 10.64.0.1]
        D -->|10.64.0.0/16| H
    end

    %% Région Asie
    subgraph RegionAsie [Région Asie]
        E[Switch 2 Asie
        VLAN 30]
        I[Routeur 1 Asie
        VLAN 30: 10.128.0.1]
        E -->|10.128.0.0/16| I
    end

    %% Région Mandarine (Sous-réseau)
    subgraph RegionMandarineSub [Région Mandarine ]
        F[Switch 1 Mandarine
        VLAN 40]
        J[Routeur 1 Mandarine
        VLAN 40: 10.192.0.254]
        F -->|10.192.0.0/16| J
    end

    %% Connexions entre les différentes régions
    B --> C
    B --> D
    B --> E
    B --> F
```

- [schéma reseau de l'infrastructure publique](./doc/schema-reseau/schéma-reseau-publique.md)

### Schéma réseau mandarine
```mermaid
flowchart BT
    subgraph s1["Public"]
        n1(("R1-FAI"))
        n2["S1-FAI"]
        n3["Douglas01"]
        n4["srv-dns-iut"]
        n5["srv-dns-iut-secours"]
        n6["srv-dns-mandarine"]
        n7["srv-dns-mandarine-secours"]
        n8["srv-mail/web"]
    end

    subgraph s2["Réseau Interne"]
        n9["firewall"]
        n12["Douglas03"]
    end

    subgraph s4["Réseau informatique"]
        n13["Douglas02"]
        n15["srv-dhcp"]
        n16["srv-ldap"]
        n17["srv-nfs"]
    end

    subgraph s5["Réseau administratif"]
        n14["Douglas03"]
        n18["station-france"]
        n19["station-belgique"]
    end

    subgraph s3["Réseau privé"]
        n10(("R2-mandarine"))
        n11["S2-mandarine"]
        s4
        s5
    end

    subgraph s6["Mandarine"]
        s1
        s2
        s3
    end

    n1 --- n2
    n2 --- n3
    n3 --- n4
    n3 --- n5
    n3 --- n6
    n3 --- n7
    n3 --- n8
    n10 --- n11
    n12 --- n9
    n15 --- n13
    n16 --- n13
    n17 --- n13
    n13 --- n11
    n9 --- n1
    n9 --- n10
    n18 --- n14
    n19 --- n14
    n14 --- n11

    %% Classes
    class n1,n10 routeur
    class n2,n11 switch
    class n3,n4,n5,n6,n7,n8,n12,n13,n14,n15,n16,n17,n18,n19 station
    class n9 firewall

    %% Style des classes
    classDef switch stroke-width:2px, stroke-dasharray:0, stroke:#2962FF, fill:#BBDEFB, color:#424242
    classDef station stroke:#00C853, fill:#C8E6C9, color:#424242
    classDef firewall stroke-width:2px, stroke-dasharray:0, stroke:#D50000, fill:#FFCDD2, color:#424242
    classDef routeur stroke-width:2px, stroke-dasharray:0, stroke:#000000, fill:#757575, color:#FFFFFF
```

- [schéma reseau de l'infrastructure mandarine](./doc/schema-reseau/schema-reseau-mandarine.md)

---

### Statut d'avancement du projet
#### Tâches terminées

##### Réseau Public
- **Attribution d'une plage d'adresses IP** pour toutes les organisations.
- Configuration des serveurs DNS :
  - **DNS autoritaire** pour le domaine `.iut`.
  - **DNS autoritaire** pour le domaine `mandarine.iut`.
  - **DNS secondaire** (de secours) pour le domaine `.iut`.
  - **DNS secondaire** (de secours) pour le domaine `mandarine.iut`.
- Mise en place de :
  - **Un serveur mail** pour le domaine `mandarine.iut`.
  - **Un serveur web** pour le domaine `mandarine.iut`.

##### Réseau Privé
- **Sécurisation du réseau privé** grâce à un firewall.

###### Réseau Informatique
- Déploiement des services suivants :
  - **DHCP** pour la gestion dynamique des adresses IP.
  - **LDAP** pour la gestion centralisée des utilisateurs.
  - **NFS** pour le partage des fichiers.
  - Un service de backup pour le service NFS et LDAP
- Configuration d'une **station de travail** équipée de :
  - Un navigateur web.
  - Un outil de gestion des emails via **Rainloop** (interface web).

###### Réseau Administratif
- Mise en place de deux **stations de travail** disposant de :
  - Un navigateur web.
  - Un outil de gestion des emails via **Rainloop** (interface web).

#### Tâches non terminées
- NFSv4
- Service en ipv6
- Vpn
- Accès Wifi

### Points Bloquants 
- Problème concernant l'adressage du réseau Public. 
- Connection entre **LDAP** et **NFS**. 
- Fournir les routes par **DHCP**.
- Bonnes résolutions pour les fichiers de configurations du **DNS** `.iut`. 
- Mise en Place du Firewall en lien avec l'infrastructure.
- Mise en place de Kerberos.
- Très mauvaise communication dans le groupe.

---

## Comptes Rendus

### Comptes Rendus des Étudiants
- [Compte rendu Halim BENIA LATRECHE](./projet/cr-etudiant/cr-halim-benia-latreche-etu.md)
- [Compte rendu Adham BERRAKANE](./projet/cr-etudiant/cr-adham-berrakane-etu.md)
- [Compte rendu Arthur KELLER](./projet/cr-etudiant/cr-arthur-keller-etu.md)
- [Compte rendu Gabriel ROBAT](./projet/cr-etudiant/cr-gabriel-robat-etu.md)

### Hebdomadaires
- [2024-10-03](./projet/cr-hebdomadaire/cr-2024-10-03-bilan-hebdo.md)
- [2024-10-18](./projet/cr-hebdomadaire/cr-2024-10-18-bilan-hebdo.md)
- [2024-11-14](./projet/cr-hebdomadaire/cr-2024-11-14-bilan-hebdo.md)
- [2024-12-13](./projet/cr-hebdomadaire/cr-2024-12-13-bilan-hebdo.md)
- [2025-01-06](./projet/cr-hebdomadaire/cr-2025-01-06-bilan-hebdo.md)

## Documentation

### Adressage IP
- [Tableau d'adressage IP](./doc/table-adressage.md)

### Schémas Réseaux
- [Schéma du réseau public](./doc/schema-reseau/schéma-reseau-publique.md)
- [Schéma du réseau privé Mandarine](./doc/schema-reseau/schéma-reseau-publique.md)

### Configuration des Routeurs et Switches
#### Routeurs
- [Routeur 1 FAI (réseau public)](./doc/configuration/fai/fai-r1.conf)
- [Routeur 2 Mandarine (réseau privé)](./doc/configuration/mandarine/mandarine-r2.conf)

#### Switches
- [Switch 1 FAI (réseau public)](./doc/configuration/fai/fai-s1.conf)
- [Switch 2 Mandarine (réseau privé)](./doc/configuration/mandarine/mandarine-s2.conf)

---

### Réseau Public

#### Serveurs DNS `.iut`
- [Documentation du DNS `.iut`](./doc/dns/dns-iut.md)
- [Documentation du DNS secondaire `.iut`](./doc/dns/dns-iut-secours.md)

#### Serveurs DNS `mandarine.iut`
- [Documentation du DNS `mandarine`](./doc/dns/dns-mandarine.md)
- [Documentation du DNS secondaire `mandarine`](./doc/dns/dns-mandarine-secours.md)

#### Serveur Web
- [Documentation sur le serveur web](./doc/web/serveur-web.md)

#### Serveur Mail
- [Installation du serveur mail](./doc/mail/installation-serveur-mail.md)
- [Ajout d'un domaine dans Postfix](./doc/mail/ajouter-domaine-postfix.md)
- [Ajout d'une adresse mail dans Postfix](./doc/mail/ajouter-adresse-mail.md)
- [Ajout d'un domaine dans Rainloop](./doc/mail/ajouter-domaine-rainloop.md)
- [Gestion des emails via Rainloop](./doc/mail/gerer-mails.md)
- [Installation de spamassassin](./doc/mail/installation-spamassassin.md)

---

### Réseau Privé

#### Serveur DHCP
- [Documentation sur le serveur DHCP](./doc/dhcp/dhcp.md)

#### Serveur LDAP
- [Documentation sur le serveur LDAP](./doc/ldap/ldap.md)

#### Serveur NFS
- [Documentation sur le serveur NFS](./doc/nfs/nfs.md)

#### Stations de Travail
- [Documentation sur les stations de travail](./doc/stations-travail/stations-travail.md)

#### Serveur Backup (NFS/LDAP)
- [Documentation sur les stations de travail](./doc/backup/backup.md)

---

### Firewall
- [Configuration du firewall](./doc/firewall/firewall.md)