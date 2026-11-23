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

## APK et IPA avec GitHub Actions

Le workflow [Mobile - APK et IPA de test](.github/workflows/mobile-test-builds.yml) reprend le fonctionnement des installateurs de test du dépôt `alina` : lancement manuel, configuration des serveurs au lancement et téléchargement des fichiers dans les artifacts.

1. Commiter et pousser le workflow sur la branche par défaut du dépôt pour rendre le bouton de lancement disponible.
2. Ouvrir **Actions → Mobile - APK et IPA de test → Run workflow** et choisir la branche à compiler.
3. Renseigner `api_url` (URL publique de l'API, suffixe `/api` inclus) et `livekit_url` (URL `wss://` publique du serveur LiveKit), puis lancer le workflow.
4. À la fin de l'exécution, télécharger `alina-test-android-<numéro>` et `alina-test-ios-<numéro>` dans **Artifacts**. Ils sont conservés 14 jours et contiennent le fichier mobile, `SHA256SUMS.txt` et un manifeste avec le commit compilé.

Les builds utilisent Flutter `3.44.8`, la version du SDK utilisée par le projet, et le numéro de l'exécution comme numéro de build. Chaque plateforme exécute l'analyse Dart et les tests avant compilation. Le fichier `.env` est créé sur les runners à partir des deux URL ; ces valeurs sont embarquées dans l'application et doivent rester publiques.

Le job iOS sélectionne explicitement Xcode `26.1.1` sur `macos-15`, conformément aux [prérequis de connectivity_plus](https://github.com/fluttercommunity/plus_plugins/tree/main/packages/connectivity_plus/connectivity_plus#requirements). L'ancien Xcode sélectionné par défaut provoque l'erreur Swift `Value of type 'NWPath' has no member 'isUltraConstrained'`. Les versions de Xcode et du SDK iOS sélectionnées sont affichées dans les logs avant compilation.

- **Android** : APK universel en mode release, signé avec la clé de debug du runner comme prévu par la configuration Android actuelle. Il est installable pour les tests. La clé peut changer entre deux exécutions ; dans ce cas, désinstaller l'ancienne version avant d'installer la nouvelle (cela efface ses données locales).
- **iOS** : IPA **non signée**, compilée sur macOS et nommée `alina-test-ios-unsigned-<numéro>.ipa`. Elle doit être signée avec un certificat et un profil de provisioning Apple appropriés avant installation sur iPhone. Aucun secret Apple n'est nécessaire pour générer ce fichier. Cette IPA ne peut pas être envoyée telle quelle à TestFlight ou à l'App Store.
