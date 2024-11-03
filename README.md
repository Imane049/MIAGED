
# Démo de l'application - Boutique de vêtements

Ce projet présente une application mobile pour une boutique de vêtements, permettant aux utilisateurs de parcourir les articles, voir les détails, ajouter des articles au panier, gérer leur profil, et plus encore. L'application suit les méthodologies agiles, et chaque fonctionnalité est définie par une user story. Vous trouverez ci-dessous les vidéos de démonstration pour chaque user story, ainsi que les identifiants de connexion pour tester l'application.

## Table des Matières
1. [User Stories](#user-stories)
2. [Vidéos de Démo](#videos-de-demo)
3. [Utilisateurs de Test](#utilisateurs-de-test)


---

## User Stories

1. **US#1** : Interface de connexion - Permet aux utilisateurs de se connecter à l'application.


https://github.com/user-attachments/assets/4cb241e3-e5ef-49f2-810d-d91aa6c19a1d


2. **US#2** : Liste des vêtements - Affiche une liste des vêtements disponibles.
   

https://github.com/user-attachments/assets/0725711f-aee4-4021-bdf5-d9ec46f690e6


4. **US#3** : Détails d'un vêtement - Montre les détails de chaque article de vêtement.

   

https://github.com/user-attachments/assets/ded12de6-e1d3-47ff-aa66-174b9c435746


6. **US#4** : Panier - Permet aux utilisateurs de voir et gérer les articles dans leur panier.


https://github.com/user-attachments/assets/8636d9a1-13ca-46d5-bafc-f59d31b97954


  
7. **US#5** : Profil utilisateur - Permet aux utilisateurs de consulter et de mettre à jour leurs informations de profil.



https://github.com/user-attachments/assets/ec61276a-340b-4253-b345-07b1bc781006


   
8. **US#6** : Ajout d'un nouveau vêtement - Permet d'ajouter de nouveaux articles de vêtements.



https://github.com/user-attachments/assets/5373af4f-36de-4f6d-8b4e-ff61626912a9
8. **Démo complète** :Démo complète avec switch entre utilisateurs.

https://github.com/user-attachments/assets/d65b90b8-ccb5-4acb-986c-899152ee325e


## Utilisateurs de Test

Pour les tests, vous pouvez utiliser les comptes suivants :

- **Utilisateur 1** :
  - **Identifiant** : `user1@email.com`
  - **Mot de passe** : `password1`

- **Utilisateur 2** :
  - **Identifiant** : `user2@email.com`
  - **Mot de passe** : `password2`

## Modèle de Précision

L'application utilise un modèle de reconnaissance d'image avec **TensorFlow Lite (TFLite)** pour classifier les vêtements, avec une précision de **0.6** (60%). Notez que TFLite n'est **pas compatible avec le web**, il est donc préférable d'utiliser un appareil physique Android ou un émulateur Android pour garantir le bon fonctionnement de l'application. Vous pouvez tester les performances du modèle en utilisant les images disponibles dans le dossier **testModel** de ce dépôt.


