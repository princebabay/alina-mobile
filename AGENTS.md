# Alina Mobile

Application Flutter dédiée au rôle `CLIENT`. Les utilisateurs peuvent se connecter, rejoindre une session, échanger des messages et voter dans les sondages. Ne pas ajouter de fonctions DJ ni de capture audio ou vidéo.

## Architecture

- `lib/services/` : contrats HTTP et connexion LiveKit.
- `lib/handlers/` : orchestration de l'authentification, de la session et des interactions.
- `lib/screens/` : navigation et état de l'interface.
- `lib/widgets/` : composants réutilisables.
- `lib/types/` : modèles et sérialisation.

Le frontend dans `../alina/frontend` sert de référence en lecture seule pour les API, les topics LiveKit et l'identité visuelle. Ne modifier que `alina-mobile`.

## Conventions

- Garder l'application légère pour les appareils Android modestes.
- Nettoyer les listeners et timers LiveKit à la sortie de la room.
- Valider les réponses API avant de mettre à jour l'interface.
- Le code d'inscription à six chiffres est vérifié avant de stocker les tokens.
- Couleurs de la marque : nuit chaude, ambre, braise et crème dans `app_colors.dart`.
- Vérifier avec `flutter test --no-pub` et `dart analyze lib test`.
