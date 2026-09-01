# Création de la page Home

Implémente maintenant la **page Home** de l'application Flutter en respectant le contexte, l'architecture des widgets et le design global définis dans les prompts précédents.

## 1. Logique existante

Le handler `HomeHandler` existe déjà et doit être utilisé.

Il contient notamment :

```dart
HomeHandler.joinRoom({required String code})
```

et :

```dart
HomeHandler.deconnexion()
```

**Ne recrée pas leur logique.**

La page Home doit appeler directement ces méthodes.

### Rejoindre une session

Lorsque l'utilisateur appuie sur le bouton **"Rejoindre une session"** :

1. récupérer le code saisi ;
2. appeler `HomeHandler.joinRoom(code: code)` ;
3. afficher un état de chargement pendant l'opération ;
4. si le résultat est `null`, la connexion à la room est réussie ;
5. si le résultat est un `String`, afficher ce message avec le widget `AppMessage` ;
6. après une connexion réussie, naviguer vers la page Salle.

Le code doit contenir exactement **6 caractères**.

L'utilisateur doit pouvoir saisir des **chiffres et des lettres**.

### Déconnexion

Ajouter un bouton **"Se déconnecter"**.

Lorsqu'il est utilisé :

```dart
HomeHandler.deconnexion()
```

Si la déconnexion réussit, rediriger l'utilisateur vers la page Auth.

Gérer également l'état de chargement pendant la déconnexion.

## 2. Interface obligatoire

La page doit contenir au minimum :

* le logo Alina ;
* un titre d'accueil ;
* une courte description/instruction ;
* un champ permettant de saisir le code de session de 6 caractères ;
* un bouton **"Rejoindre une session"** ;
* un bouton **"Se déconnecter"** ;
* l'affichage des erreurs avec `AppMessage`.

Le champ de code doit être visuellement composé de **6 cases distinctes**, tout en permettant une saisie simple et naturelle.

Le focus et le déplacement entre les cases doivent être correctement gérés.

## 3. Widgets réutilisables

Avant de créer de nouveaux widgets, **vérifie les widgets déjà présents dans `widgets/common/`**.

Réutilise ceux qui sont adaptés, notamment :

```text
widgets/common/
├── app_logo.dart
├── app_text_field.dart
├── app_button.dart
└── app_message.dart
```

Si un widget existant peut être légèrement amélioré pour être réutilisable dans Home, privilégie cette solution plutôt que de créer un doublon.

Ne crée pas plusieurs composants qui font la même chose.

Si le champ de code à 6 cases nécessite un widget spécifique, crée-le dans :

```text
widgets/home/
```

## 4. Navigation

La page Home doit avoir les comportements suivants :

```text
Rejoindre une session
        ↓
HomeHandler.joinRoom()
        ↓
     succès
        ↓
      Salle
```

et :

```text
Se déconnecter
        ↓
HomeHandler.deconnexion()
        ↓
     succès
        ↓
      Auth
```

Utilise les routes/navigation déjà présentes dans le projet.

**Ne recrée pas un système de navigation parallèle.**

## 5. Design

Respecte strictement le thème global défini précédemment :

* thème sombre ;
* background `#08080D` ;
* surfaces `#0B0B11`, `#101018`, `#16161F` ;
* rose principal `#FF3D9A` ;
* gradient `#FF5AA8 → #D81F78` ;
* texte principal `#EDECF3` ;
* textes secondaires gris/violet ;
* bordures discrètes ;
* coins arrondis ;
* boutons modernes ;
* glow rose subtil ;
* style premium et légèrement inspiré de Discord.

Utilise le logo Alina existant.

La page doit être visuellement cohérente avec la page Auth.

## 6. Responsive et performances

L'application cible principalement des smartphones Android, notamment des appareils bas de gamme.

Prioriser :

* simplicité ;
* performances ;
* faible consommation de ressources ;
* responsive ;
* bonne lisibilité.

Évite les animations lourdes, les effets complexes et les dépendances inutiles.

## 7. Architecture

Le fichier actuel :

```text
screens/home_screen.dart
```

est seulement une version de test avec :

```text
Bienvenue
```

Tu peux le remplacer complètement.

Organise les widgets spécifiques à Home dans :

```text
widgets/home/
```

et réutilise les widgets génériques de :

```text
widgets/common/
```

Ne modifie pas `HomeHandler`, `AuthService`, `LivekitService` ou `StorageUtil` sauf si une modification est absolument nécessaire.

## 8. Vérification finale

Après l'implémentation :

* vérifie que les boutons fonctionnent ;
* vérifie les états de chargement ;
* vérifie l'affichage des erreurs ;
* vérifie la saisie des 6 caractères ;
* vérifie la navigation Home → Salle ;
* vérifie la navigation Home → Auth après déconnexion ;
* vérifie que le projet compile.

Ne modifie pas les fonctionnalités qui ne concernent pas Home.
