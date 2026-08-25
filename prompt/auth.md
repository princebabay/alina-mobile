# Création de la page Auth

Implémente maintenant la **page Auth complète** de l'application Flutter en respectant le contexte et le design global définis dans les prompts précédents.

## 1. Architecture des widgets

L'application doit utiliser une séparation claire entre les widgets réutilisables et les widgets spécifiques à l'authentification.

Structure souhaitée :

```text
lib/
├── handlers/
│   ├── auth/
│   │   ├── login_handler.dart
│   │   └── register_handler.dart
│   └── room/
│
├── screens/
│   ├── auth_screen.dart
│   └── home_screen.dart
│
├── services/
├── types/
├── utils/
│
└── widgets/
    ├── common/
    │   ├── app_logo.dart
    │   ├── app_text_field.dart
    │   ├── app_button.dart
    │   └── app_message.dart
    │
    └── auth/
        ├── login_form.dart
        └── register_form.dart
```

Les widgets dans `common/` doivent être suffisamment génériques pour pouvoir être réutilisés plus tard dans **Home** et **Salle**.

Les widgets dans `auth/` doivent uniquement contenir ce qui est spécifique au Login et au Register.

## 2. Login

Utilise obligatoirement le handler existant :

```dart
LoginHandler.submit(
  email: ...,
  motDePasse: ...,
);
```

Le résultat fonctionne ainsi :

```text
null   → connexion réussie
String → erreur
```

Pendant la requête, afficher un état de chargement et empêcher une nouvelle soumission.

Si la connexion réussit :

```text
Login → Home
```

Pour l'instant, crée un **Home très simple** permettant de vérifier la navigation, avec simplement un texte :

```text
Bienvenue
```

## 3. Vérification d'une session existante

`LoginHandler.initialize()` doit être appelé **lors de l'initialisation de `AuthScreen`**.

Son comportement est :

```text
true  → aucune session valide → rester sur Auth
false → refresh token valide → rediriger directement vers Home
```

Donc :

```text
AuthScreen démarre
        ↓
LoginHandler.initialize()
        ↓
   ┌────┴────┐
 true       false
  ↓           ↓
Auth         Home
```

Ne pas afficher brièvement l'écran Login avant la redirection si une session valide existe. Utilise un état de chargement/initialisation approprié.

## 4. Register

Utilise obligatoirement :

```dart
RegisterHandler.submit(
  nomUtilisateur: ...,
  email: ...,
  motDePasse: ...,
  confirmationMotDePasse: ...,
);
```

Le résultat :

```text
null   → inscription réussie
String → erreur
```

Après une inscription réussie, rediriger vers **Home**.

## 5. Interface Auth

Créer une interface moderne comprenant :

### Login

* Logo Alina
* Titre
* Sous-titre
* Email
* Mot de passe
* Bouton "Se connecter"
* Loading
* Message d'erreur
* Lien vers Register

### Register

* Logo Alina
* Titre
* Sous-titre
* Nom d'utilisateur
* Email
* Mot de passe
* Confirmation du mot de passe
* Bouton "S'inscrire"
* Loading
* Message d'erreur
* Lien vers Login

Le passage Login ↔ Register doit être fluide et conserver le même design.

## 6. Widgets communs

Les composants suivants doivent être créés dans `widgets/common/` :

* `AppLogo`
* `AppTextField`
* `AppButton`
* `AppMessage`

Ils doivent être conçus comme des composants génériques et réutilisables.

Par exemple, `AppTextField` ne doit pas contenir de logique spécifique au Login ou au Register.

## 7. Design

Respecte le thème global défini précédemment :

* thème sombre
* background `#08080D`
* surfaces `#0B0B11`, `#101018`, `#16161F`
* rose principal `#FF3D9A`
* gradient `#FF5AA8 → #D81F78`
* texte principal `#EDECF3`
* textes secondaires gris/violet
* bordures discrètes
* coins arrondis
* boutons avec gradient rose
* glow rose subtil
* style moderne, premium, légèrement inspiré de Discord

Utiliser :

```text
assets/images/alina.png
assets/images/alina-square.png
```

selon le contexte.

## 8. Android bas de gamme

L'application cible notamment des appareils Android bas de gamme.

Prioriser :

* performances
* simplicité
* faible consommation de ressources
* interface responsive
* lisibilité

Éviter les animations lourdes et les dépendances inutiles.

## 9. Règles importantes

Les handlers et services existent déjà.

**Ne recrée aucune logique d'authentification.**

Utilise :

* `LoginHandler`
* `RegisterHandler`
* `AuthService`
* `StorageUtil`

Ne modifie pas leur logique sauf si une modification est absolument nécessaire.

Les anciens :

* `login_form.dart`
* `register_form.dart`
* `auth_screen.dart`

sont des versions de test. Tu peux les refactorer/remplacer complètement pour obtenir la nouvelle interface.

Avant de coder, inspecte uniquement les fichiers nécessaires pour comprendre les routes/navigation existantes.

À la fin, vérifie que le projet compile et corrige uniquement les problèmes liés à cette implémentation.
