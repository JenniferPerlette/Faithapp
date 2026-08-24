# FaithFocus

Application mobile Flutter destinée aux chrétiens, combinant :

1. **Jeûne Digital** — blocage natif des apps du téléphone pendant une
   plage horaire ou un minuteur, avec une whitelist (FaithFocus + une app
   biblique tierce).
2. **Quiz bibliques gamifiés** façon Duolingo — leçons, XP, streaks,
   classement entre amis.

## Stack technique

- **Flutter/Dart** pour le cross-platform, **Riverpod** pour la gestion
  d'état, **Hive** pour le stockage local offline-first.
- **Kotlin** côté Android : `AccessibilityService` pour la détection
  d'app au premier plan, overlay Jetpack Compose, stockage chiffré
  (`EncryptedSharedPreferences`).
- **Swift** côté iOS : `FamilyControls` / `ManagedSettings` /
  `DeviceActivity` (Screen Time API), extensions Shield.
- **Backend Firebase** : Firestore, Auth, Cloud Functions (TypeScript).

## Structure du projet

```
lib/
├── core/
│   ├── platform/      # AppBlockerChannel (pont MethodChannel Dart ↔ natif)
│   ├── services/      # AuthService, SyncService, NotificationService (stubs)
│   ├── models/         # Modèles Quiz partagés (sérialisation Firestore)
│   └── theme/          # Palette de couleurs plate + thème Material 3
├── features/
│   ├── focus_mode/     # Config + session active du Jeûne Digital
│   ├── quiz/            # Moteur de quiz + UI de leçon
│   ├── gamification/    # Streak local optimiste + classement
│   └── onboarding/      # (non implémenté)
└── main.dart

android/app/src/main/kotlin/.../   # Service d'accessibilité, overlay, plugin
ios/Runner/, ios/*Extension/       # ScreenTimeManager, Shield, extensions
functions/src/                     # Cloud Functions (soumission de leçon, leaderboard)
docs/manual-tests/                 # Checklists de test manuel sur device réel
docs/task10-integration-review.md  # Revue de conformité et checklist de publication
```

## Prérequis avant de lancer le projet

1. **Configuration Firebase** — créer un projet Firebase et y déposer :
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

   Ces fichiers sont volontairement absents du dépôt (spécifiques à votre
   projet Firebase) et ignorés par `.gitignore`.
2. **Android** : SDK Android complet (`cmdline-tools`, platform 36,
   build-tools, NDK — cf. `docs/manual-tests/task4-android-accessibility-blocking.md`
   pour le détail des permissions à accorder manuellement sur device).
3. **iOS** : macOS + Xcode. Les cibles d'extension
   (`DeviceActivityMonitorExtension`, `ShieldConfigurationExtension`,
   `ShieldActionExtension`) doivent être créées manuellement dans Xcode —
   suivre `docs/manual-tests/task6-ios-xcode-setup.md`. L'entitlement
   `com.apple.developer.family-controls` nécessite une approbation Apple.

## Lancer le projet

```bash
flutter pub get
flutter run
```

## Tests

```bash
# Flutter — utiliser --concurrency=1 (bug connu de découverte de tests en
# concurrence par défaut sur certains environnements, cf. mémoire projet)
flutter test --concurrency=1

# Cloud Functions
cd functions
npm install
npm test
npm run build
```

## État d'avancement

Les 10 tâches du plan de développement initial sont traitées. Voir
**`docs/task10-integration-review.md`** pour le détail complet : permissions
manquantes avant soumission aux stores, tests manuels restants, TODO
techniques, et revue de conformité OWASP.

Points à connaître en priorité :

- **Aucune authentification Firebase n'est encore branchée côté Flutter**
  (`AuthService` reste un stub) : le modèle de sécurité serveur
  (Firestore Rules, Cloud Functions) est en place mais pas encore
  atteignable depuis l'app.
- Le résultat d'une leçon de quiz n'est pas encore envoyé à la Cloud
  Function `submitLessonResult` — le moteur de quiz et son UI ne
  fonctionnent aujourd'hui qu'en local, avec des données de test en dur.
- Le code natif iOS n'a pas pu être compilé dans l'environnement de
  développement utilisé (pas de macOS disponible) — à valider en priorité
  sur un Mac avant toute publication iOS.
