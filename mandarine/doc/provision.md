# Provision des différents serveurs et postes

Cette procédure explique comment provisionner les serveurs et postes avec les scripts de déploiement.

## Étapes pour la provision

Pour provisionner les serveurs, suivez ces étapes simples :

### 1. Copier le dossier `provision` sur la machine cible

1. Identifiez la machine Douglas que vous souhaitez configurer.  
2. Copiez le dossier [provision](../bin/provision) vers cette machine en utilisant la commande suivante (remplacez `X` par le numéro de la machine) :  

   ```bash
   scp -r provision cisco@Douglas0X:~/
   ```

### 2. Exécuter le script de déploiement

1. Une fois le dossier copié, connectez-vous à la machine cible et exécutez les commandes suivantes :  

   ```bash
   cd provision
   ./deploy.sh
   ```

2. Lors de l’exécution, le script vous demandera de spécifier la machine cible en entrant son numéro. Appuyez sur la touche **Entrée** après avoir saisi le numéro.  

3. Le script effectuera automatiquement les étapes suivantes :  
   - Création des machines virtuelles via `Vagrant`.  
   - Configuration du provisionnement pour chaque machine.  
   - Attribution d’une adresse IP et configuration des routes nécessaires au bon fonctionnement des machines Douglas.  

## Configuration du serveur mail

**Note importante :**  
Pour le serveur mail, une partie de la configuration doit être effectuée manuellement.  
Suivez la procédure détaillée ici : [Installation du serveur mail](./mail/installation-serveur-mail.md).  
