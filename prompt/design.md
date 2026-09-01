# Design global de l'application

Avant de créer les différentes pages, définis et applique une direction visuelle cohérente à toute l'application Flutter en te basant sur le thème de la version web existante.

## Identité visuelle

L'application utilise un thème sombre, moderne et premium, inspiré de Discord, avec une identité principalement rose.

### Couleurs principales

* Background principal : `#08080D`
* Surface : `#0B0B11`
* Surface secondaire : `#101018`
* Surface tertiaire : `#16161F`
* Texte principal : `#EDECF3`
* Texte normal : `#9D9CAF`
* Texte secondaire : `#8A8A9C`
* Texte discret : `#6A6A7C`
* Texte très discret : `#4A4A5C`
* Bordures : blanc avec faible opacité, environ `8%`

### Couleur principale

La couleur principale de l'application est le **rose** :

* Primary : `#FF3D9A`
* Primary dark : `#D81F78`
* Primary light : `#FF6FB3`

Utiliser régulièrement un dégradé allant de `#FF5AA8` vers `#D81F78`.

Le rose doit être utilisé pour :

* les boutons principaux
* les éléments actifs
* les titres importants
* certains accents
* les effets de glow subtils
* les éléments interactifs

## États

Utiliser ces couleurs pour les différents états :

* Success : `#4CAF84`
* Danger : `#FF5D6C`
* Warning : `#F5B13D`

## Style général

Le design doit être :

* sombre
* moderne
* premium
* épuré
* légèrement inspiré de Discord
* avec des surfaces légèrement différentes pour créer de la profondeur
* avec des bordures discrètes
* avec des coins arrondis
* avec des ombres légères
* avec quelques effets de glow rose très subtils

Éviter cependant de surcharger l'interface avec des effets visuels.

## Typographie

Utiliser une police proche de **Inter**.

Si Inter n'est pas disponible nativement, utiliser une police système moderne équivalente.

Hiérarchie :

* titres : gras / très gras
* sous-titres : taille moyenne, couleur secondaire
* labels : petits, visibles et légèrement espacés
* texte principal : clair mais pas blanc pur

## Boutons

Les boutons principaux doivent reprendre le style suivant :

* fond en dégradé rose
* texte blanc
* coins arrondis
* légère ombre/glow rose
* hauteur confortable
* état disabled avec opacité réduite

Prévoir également des variantes :

* bouton secondaire
* bouton transparent/ghost
* bouton danger
* bouton success

Les interactions doivent rester discrètes et adaptées au mobile.

## Champs de formulaire

Les champs doivent avoir :

* fond `#101018` ou `#16161F`
* bordure discrète
* coins arrondis
* texte clair
* placeholder discret
* focus avec bordure rose
* léger glow rose autour du champ lors du focus
* état d'erreur avec la couleur danger

Les labels doivent être petits, lisibles et légèrement espacés.

## Logo

Les fichiers du projet sont :

```text
assets/
└── images/
    ├── alina.png
    ├── alina-square.png
    └── aline.ico
```

Utiliser :

* `alina.png` lorsque le logo avec son format complet est nécessaire
* `alina-square.png` lorsque seule l'icône carrée est nécessaire
* `aline.ico` uniquement lorsque nécessaire pour l'icône de l'application desktop/Windows

Le logo carré peut avoir un léger glow rose lorsqu'il est utilisé comme élément décoratif important.

## Responsive / mobile

L'application est destinée principalement aux appareils Android, notamment des appareils bas de gamme.

Priorités :

1. simplicité
2. performances
3. lisibilité
4. responsive
5. esthétique

Éviter :

* animations lourdes
* effets graphiques complexes
* widgets inutilement coûteux
* dépendances supplémentaires uniquement pour des effets visuels

Les effets de gradient, glow et ombres doivent rester légers.

## Règle importante pour les prochaines pages

Cette direction visuelle doit être utilisée comme **référence globale** pour toutes les pages :

* Auth
* Home
* Salle

Les pages doivent avoir une identité visuelle cohérente.

Ne recrée pas la logique métier, les services ou les handlers existants pour réaliser le design. Utilise les composants et fonctionnalités déjà disponibles dans le projet.
