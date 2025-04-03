# Procédure pour ajouter des domaines dans Postfix

Cette procédure explique comment ajouter ou consulter les domaines dans Postfix.

## Connexion à Postfix en tant qu'administrateur

Pour accéder à l'interface administrateur de Postfix, procédez comme suit :  

1. Ouvrez un navigateur web, comme **Firefox**.  
2. Saisissez l’adresse suivante dans la barre de recherche :  
   [http://10.192.0.3/postfixadmin/login.php](http://10.192.0.3/postfixadmin/login.php)

3. Une interface semblable à celle-ci devrait s’afficher :  
   ![Interface de connexion de Postfix pour les administrateurs](../photos/ajouter-adresse/formulaire-connexion.png)

4. Connectez-vous avec les identifiants administrateurs :  
   - **Identifiant** : `admin@mandarine.iut`  
   - **Mot de passe** : `mandarine123!`

5. Une fois connecté, vous accéderez à l’interface administrateur :  
   ![Interface administrateur Postfix](../photos/ajouter-adresse/interface.png)

## Ajouter un domaine

1. Dans l’interface administrateur, cliquez sur **Liste des domaines**, puis sur **Nouveau domaine**.  
   ![Ajouter un nouveau domaine](../photos/ajouter-domaine/ajouter-domaine.png)

2. Vous serez redirigé vers un formulaire permettant l’ajout d’un domaine :  
   ![Formulaire d'ajout d'un domaine](../photos/ajouter-domaine/formulaire.png)

3. Remplissez le formulaire avec les informations requises :  
   - Nom du domaine  
   - Description  
   - Alias (si nécessaire)  
   - Autres paramètres spécifiques.  

4. Après avoir complété toutes les informations, cliquez sur **Ajouter un domaine** pour valider.

## Consulter la liste des domaines

1. Dans l’interface administrateur, cliquez sur **Liste des domaines**, puis sur **Liste des domaines**.  
   ![Liste des domaines](../photos/ajouter-domaine/ajouter-domaine.png)

2. Une page récapitulative des domaines enregistrés s’affichera :  
   ![Liste des domaines](../photos/ajouter-domaine/ListeDesDomaines.png)

   Vous pourrez y consulter tous les domaines existants ainsi que leurs paramètres associés.
