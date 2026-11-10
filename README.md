# Alina Mobile

Application Flutter pour rejoindre une room Alina en tant que client, envoyer des messages et voter aux sondages.

## Configuration

Définir `API_URL` et `VITE_LIVEKIT_URL` dans `.env` (voir `.env.example`), puis lancer :

```sh
flutter pub get
flutter run
flutter build apk --release
```

L'inscription envoie un code à six chiffres par email. Les tokens sont enregistrés localement après sa vérification. La room utilise l'API pour conserver les messages et les votes, et LiveKit pour notifier les autres participants.

## Vérification

```sh
flutter test --no-pub
dart analyze lib test
```
