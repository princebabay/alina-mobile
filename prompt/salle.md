# Création de la page Salle

Implémente maintenant la **page Salle complète** de l'application Flutter.

L'objectif principal est de créer une interface **simple, immersive, moderne et optimisée pour l'espace**, particulièrement adaptée aux smartphones Android et aux appareils bas de gamme.

Respecte le thème graphique et l'architecture définis dans les prompts précédents.

---

## 1. Logique existante

Le handler existe déjà dans :

```text
lib/handlers/room/salle_handler.dart
```

Il contient :

```dart
SalleHandler.initialize(...)
SalleHandler.quitterSalle()
SalleHandler.toggleCamera(...)
SalleHandler.toggleMicrophone(...)
```

Utilise ces méthodes.

**Ne recrée pas leur logique et ne modifie pas `SalleHandler`.**

À l'ouverture de la Salle, appelle :

```dart
SalleHandler.initialize(...)
```

et utilise ses callbacks pour maintenir l'état de l'interface :

* `setIsEnDirect`
* `setIsConnected`
* `setCameraEnabled`
* `setRoomName`
* `setLocalVideoTrack`
* `setMicrophoneEnabled`
* `setRemoteVideoTrack`
* `setRemoteAudioTrack`

---

## 2. LiveKit

`LivekitService` contient déjà les fonctionnalités nécessaires.

Tu peux consulter et utiliser ses méthodes existantes.

**Ne modifie aucune méthode existante de `LivekitService`.**

Pour l'analyse audio, utilise :

```dart
LivekitService.analyzeAudio(
  track,
  (level) {
    ...
  },
);
```

Le niveau fourni est compris entre :

```text
0 → 100
```

Utilise-le pour alimenter le visualizer audio.

---

# 3. Priorité UX : optimiser l'espace

La page ne doit **pas être surchargée**.

La vidéo du DJ doit être l'élément principal et occuper la majorité de l'écran.

Évite les informations redondantes et les gros blocs de texte.

### Ne pas afficher :

* le texte `"Son actif sur la sono"` ;
* le texte `"Le mix passe sur les enceintes"` ;
* `"SALLE · votre caméra"` ;
* le nom de la room dans une grosse zone ;
* un gros badge `"Connecté"` ;
* des labels textuels permanents pour Caméra/Microphone ;
* un gros bloc dédié au volume.

### Simplifier :

* le statut LiveKit → petit indicateur discret ;
* Quitter → bouton compact avec icône ;
* caméra/micro → boutons principalement sous forme d'icônes ;
* volume → contrôle compact ;
* audio visualizer → petit élément visuel ;
* informations de session → uniquement celles réellement utiles.

**Ne cherche pas à afficher toutes les informations disponibles.**

L'interface doit privilégier l'expérience utilisateur plutôt que la quantité d'informations affichées.

---

# 4. Mode plein écran

Ajouter un **mode plein écran immersif**.

La Salle doit pouvoir masquer les éléments système Android afin que la vidéo utilise un maximum de surface disponible.

Prévoir également un moyen simple de sortir du plein écran si nécessaire.

Le plein écran doit être particulièrement adapté à la consultation de la vidéo du DJ.

Évite cependant de créer une interface permanente dédiée au bouton plein écran : celui-ci peut être intégré discrètement aux contrôles.

---

# 5. Structure visuelle

Organise l'écran approximativement comme ceci :

```text
┌──────────────────────────────────────┐
│ Alina   ● EN DIRECT          ⛶  ✕   │
│                                      │
│                                      │
│                                      │
│             VIDÉO DU DJ              │
│                                      │
│                                      │
│                                      │
│                         ┌────────┐   │
│                         │ CAMERA │   │
│                         │ LOCALE │   │
│                         └────────┘   │
│                                      │
│       ◀ audio visualizer ▶           │
│                                      │
│        🎤      📷      🔊             │
└──────────────────────────────────────┘
```

Ceci est une indication de composition, pas une obligation pixel-perfect.

La vidéo du DJ doit rester l'élément dominant.

---

# 6. Barre supérieure

Créer une barre supérieure très compacte.

Afficher uniquement :

### À gauche

* petit logo Alina ;
* éventuellement le nom `Alina` ;
* badge discret `EN DIRECT` uniquement lorsque `isEnDirect == true`.

### À droite

* petit indicateur de connexion LiveKit ;
* bouton plein écran ;
* bouton Quitter.

Le statut LiveKit doit être représenté principalement par un **petit indicateur visuel**, pas par un gros texte.

Par exemple :

```text
●
```

avec une couleur indiquant l'état.

---

# 7. Vidéo du DJ

La vidéo distante provenant de :

```dart
RemoteVideoTrack?
```

doit occuper la plus grande partie de l'écran.

Utilise le `RemoteVideoTrack` fourni par :

```dart
setRemoteVideoTrack
```

Si aucune vidéo n'est disponible :

* afficher un état vide propre ;
* conserver le design sombre ;
* ne pas afficher un gros message inutile.

La vidéo ne doit pas être déformée.

Utilise une stratégie d'affichage adaptée aux proportions de l'écran.

---

# 8. Caméra locale

Afficher le :

```dart
LocalVideoTrack?
```

fourni par :

```dart
setLocalVideoTrack
```

sous forme de **petite vignette flottante**.

La vignette doit :

* rester discrète ;
* avoir des coins arrondis ;
* ne pas prendre beaucoup d'espace ;
* être positionnée au-dessus de la vidéo principale ;
* être clairement identifiable visuellement sans nécessiter de texte.

---

## 9. Visualizer audio

Lorsque `RemoteAudioTrack` est disponible :

```dart
LivekitService.analyzeAudio(...)
```

doit être utilisé.

Créer un visualizer **horizontal et très léger**, sous forme d'une ligne audio :

```text
━━━━━━━━━━━━━━━━━━━━
```

La ligne doit **réagir au niveau audio** fourni par `analyzeAudio`.

Le visualizer peut par exemple varier en longueur, intensité ou animation selon le `level` reçu.

Utiliser le rose Alina.

Ne pas créer un visualizer complexe ou coûteux.

Il doit rester **très fin et compact**, afin de ne pas concurrencer la vidéo du DJ.


---

# 10. Volume

Ajouter un contrôle permettant de régler le volume :

```text
0 % ───────── 100 %
```

Mais **ne crée pas une grosse section dédiée au volume**.

Privilégie :

```text
🔊 ────────●
```

ou un bouton permettant d'afficher temporairement un slider.

Si `LivekitService` contient déjà une méthode permettant de contrôler le volume, utilise-la.

**Ne modifie pas `LivekitService`.**

---

# 11. Contrôles caméra et microphone

Ajouter les deux contrôles :

```text
🎤 Microphone
📷 Caméra
```

mais utiliser principalement des **boutons icônes compacts**.

Les états doivent être immédiatement reconnaissables :

```text
activé
désactivé
```

Utiliser :

```dart
SalleHandler.toggleCamera(etat: ...)
```

et :

```dart
SalleHandler.toggleMicrophone(etat: ...)
```

Gérer les erreurs retournées par ces méthodes.

En cas d'erreur :

```dart
AppMessage(...)
```

peut être utilisé temporairement.

Ne garde pas un gros message d'erreur permanent qui prend de la place.

---

# 12. Quitter

Le bouton Quitter doit appeler :

```dart
SalleHandler.quitterSalle()
```

Si la déconnexion réussit :

```text
Salle → Home
```

Ne quitte jamais simplement la page sans déconnecter LiveKit.

Le bouton doit être compact et facilement accessible.

---

# 13. Widgets réutilisables

Avant de créer de nouveaux widgets, inspecte :

```text
lib/widgets/common/
```

et réutilise les composants existants lorsqu'ils sont adaptés :

* `AppLogo`
* `AppButton`
* `AppMessage`
* `AppTextField`
* etc.

Ne crée aucun doublon inutile.

Les widgets spécifiques à la Salle peuvent être placés dans :

```text
lib/widgets/room/
```

Par exemple :

```text
room_header.dart
room_video.dart
room_local_preview.dart
room_audio_visualizer.dart
room_controls.dart
```

Mais ne crée un widget séparé que si cela améliore réellement la lisibilité ou la réutilisation.

---

# 14. Design

Respecte strictement le thème Alina défini précédemment :

* background `#08080D` ;
* surfaces `#0B0B11`, `#101018`, `#16161F` ;
* primaire `#FF3D9A` ;
* gradient `#FF5AA8 → #D81F78` ;
* texte principal `#EDECF3` ;
* texte secondaire gris/violet ;
* bordures discrètes ;
* coins arrondis ;
* glow rose subtil ;
* style sombre, premium et moderne.

La Salle doit être visuellement cohérente avec Auth et Home.

---

# 15. Responsive

La page doit fonctionner correctement sur différentes tailles d'écran Android.

Priorités :

1. vidéo toujours visible ;
2. contrôles accessibles ;
3. caméra locale suffisamment petite ;
4. aucun débordement ;
5. utilisation maximale de l'espace disponible.

Utilise `SafeArea` lorsque nécessaire, mais le mode plein écran doit permettre une expérience immersive.

---

# 16. Performances

L'application cible également des appareils Android bas de gamme.

Évite :

* animations lourdes ;
* effets graphiques complexes ;
* nombreuses reconstructions inutiles ;
* widgets inutiles ;
* traitements continus coûteux.

Le visualizer audio doit rester léger.

Ne recrée pas une connexion LiveKit dans la page.

La connexion existe déjà avant l'arrivée dans Salle.

---

# 17. Gestion du cycle de vie

Lors de l'ouverture :

```text
SalleScreen
   ↓
SalleHandler.initialize(...)
```

Maintenir les différents états locaux à partir des callbacks.

Lors de la destruction de la page, nettoie correctement les ressources/listeners créés par l'interface.

Ne déconnecte pas LiveKit automatiquement lors d'une destruction accidentelle du widget si cela n'est pas nécessaire : la déconnexion doit être déclenchée par le parcours prévu avec `quitterSalle()`.

---

# 18. Erreurs

Les méthodes :

```dart
SalleHandler.toggleCamera(...)
SalleHandler.toggleMicrophone(...)
```

retournent :

```dart
String?
```

Si le résultat n'est pas `null`, afficher l'erreur avec le système `AppMessage` existant.

Ne crée pas un nouveau système de notification.

---

# 19. Vérification finale

Après l'implémentation, vérifie :

* initialisation correcte de la Salle ;
* statut LiveKit ;
* statut `EN DIRECT` ;
* vidéo du DJ ;
* caméra locale ;
* activation/désactivation caméra ;
* activation/désactivation microphone ;
* visualizer audio ;
* volume 0–100 % ;
* mode plein écran ;
* sortie du plein écran ;
* bouton Quitter ;
* navigation Salle → Home ;
* affichage des erreurs ;
* responsive ;
* absence de débordement ;
* compilation du projet.

**Important : simplifie l'interface lorsqu'un élément n'apporte pas une information réellement utile.**

La priorité est :

**Vidéo du DJ > contrôles essentiels > caméra locale > audio visualizer > informations secondaires.**

Ne modifie pas les services ou handlers existants pour contourner un problème d'UI.
