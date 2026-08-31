Corrige uniquement les problèmes de permissions iOS/Android suivants. Ne modifie pas l’architecture ni les fonctionnalités existantes.

### iOS

* Supprimer la condition `Platform.isAndroid` dans la gestion des permissions afin que `permission_handler` fonctionne aussi sur iOS.
* Ajouter dans `ios/Runner/Info.plist` :

  * `NSCameraUsageDescription`
  * `NSMicrophoneUsageDescription`
* Utiliser des messages adaptés expliquant qu’Alina utilise la caméra et le microphone dans une salle.

### Android

Ajouter dans `android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
```

### Contraintes

* Ne modifier aucun fichier ou code non nécessaire.
* Ne pas modifier `LivekitService` ni `SalleHandler`.
* Vérifier que les permissions runtime caméra/micro existantes continuent de fonctionner sur Android et iOS.
* Vérifier la cohérence du code après modification.
* Résumer uniquement les changements effectués.
