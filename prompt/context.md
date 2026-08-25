Contexte du projet :

Je développe une application mobile Flutter.

La logique métier et les communications avec l'API sont déjà implémentées.
Les services et handlers nécessaires au fonctionnement de l'application existent déjà.

Structure actuelle :

lib/
├── handlers/
│   ├── auth/
│   └── room/
├── screens/
├── services/
├── types/
├── utils/
└── widgets/

Important :
- Les services contiennent les communications avec l'API et les fonctionnalités techniques.
- Les handlers contiennent la logique des actions/pages.
- Les screens doivent principalement gérer l'UI et l'état de l'écran.
- Les widgets doivent contenir les composants UI réutilisables.
- Utilise les services et handlers existants.
- Ne recrée pas une logique qui existe déjà.
- Ne modifie pas les services/handlers sauf si c'est absolument nécessaire.
- Je veux une application légère et adaptée aux appareils Android bas de gamme.
- Évite les animations lourdes et les dépendances inutiles.
- Le design doit être moderne, propre, responsive et cohérent entre les pages.

J'ai déjà créé auparavant une petite version de test du Login et du Register.
Cette version était uniquement destinée aux tests et doit maintenant être remplacée/refaite avec une vraie interface.
Il faut utiliser les services et handlers d'authentification déjà présents au lieu de recréer la logique de connexion ou d'inscription.

Les principales pages de l'application seront :
1. Auth / Login + Register
2. Accueil
3. Salle

Pour le moment, ne code aucune page.
Analyse uniquement la structure existante et les services/handlers disponibles afin de comprendre comment l'UI doit les utiliser.

Quand je te demanderai ensuite de créer une page, travaille uniquement sur cette page et ses widgets associés.