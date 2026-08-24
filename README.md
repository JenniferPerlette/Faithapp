# FaithFocus

Application mobile Flutter destinée aux chrétiens, combinant :

1. **Jeûne Digital** blocage natif des apps du téléphone pendant une
   plage horaire ou un minuteur, avec une whitelist (FaithFocus + une app
   biblique tierce).
2. **Quiz bibliques gamifiés** 

## Stack technique

- **Flutter/Dart** pour le cross-platform, **Riverpod** pour la gestion
  d'état, **Hive** pour le stockage local offline-first.
- **Kotlin** côté Android : `AccessibilityService` pour la détection
  d'app au premier plan, overlay Jetpack Compose, stockage chiffré
  (`EncryptedSharedPreferences`).
- **Swift** côté iOS : `FamilyControls` / `ManagedSettings` /
  `DeviceActivity` (Screen Time API), extensions Shield.
- **Backend Firebase** : Firestore, Auth, Cloud Functions (TypeScript).

