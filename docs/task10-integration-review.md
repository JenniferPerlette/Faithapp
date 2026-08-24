# Tâche 10 — Intégration finale et checklist de publication

Revue de l'ensemble du projet FaithFocus (Tâches 1 à 9), sans modification
de code : ce document est un état des lieux avant soumission aux stores.

---

## 1. Permissions/déclarations manquantes ou incomplètes

### Android (`android/app/src/main/AndroidManifest.xml`)

| Élément | État | Action requise |
|---|---|---|
| `SYSTEM_ALERT_WINDOW` | ✅ présent | — |
| `BIND_ACCESSIBILITY_SERVICE` sur le service | ✅ présent | — |
| `PACKAGE_USAGE_STATS` | ⚠️ présent mais inutilisé | Retirer si aucune fonctionnalité `UsageStatsManager` n'est ajoutée avant soumission (une permission déclarée et non exploitée peut être questionnée en revue Play Store), ou implémenter l'usage correspondant. |
| `INTERNET` | ❓ non déclarée explicitement dans notre manifeste | Probablement fusionnée automatiquement depuis les manifestes des plugins Firebase (`firebase_core`, `cloud_firestore`, `firebase_auth`) — à confirmer en inspectant le manifeste fusionné (`flutter build apk --analyze-size` ou `app/build/intermediates/merged_manifests`). |
| `android:label` | ✅ corrigé (`"FaithFocus"`) | — |
| Icône de lancement | ⚠️ icône par défaut Flutter | Remplacer `mipmap-*/ic_launcher.png` par une icône FaithFocus avant soumission (obligatoire pour la revue Play Store). |
| Service de premier plan (`OverlayLockScreenService`) | ⚠️ non déclaré comme foreground service | Cf. limitation notée en Tâche 5 : le démarrage depuis `BlockingAccessibilityService` (contexte non premier-plan) pourrait être soumis aux restrictions Android 8+ sur le démarrage de service en arrière-plan. Si les tests manuels (section 3) révèlent un échec de démarrage sur certains appareils/versions, il faudra ajouter `FOREGROUND_SERVICE` + `android:foregroundServiceType` + une notification associée. |
| `versionCode`/`versionName` | ℹ️ valeurs par défaut (`1.0.0+1`) | À incrémenter selon le processus de release habituel, pas un manque en soi. |

### iOS (`ios/Runner/Info.plist` et configuration Xcode)

| Élément | État | Action requise |
|---|---|---|
| `com.apple.developer.family-controls` (entitlement) | ⚠️ déclaré dans `Runner.entitlements` mais **soumis à approbation Apple** | Faire la demande auprès d'Apple (formulaire dédié) — cf. `docs/manual-tests/task6-ios-xcode-setup.md`. Sans cette approbation, la soumission sera rejetée ou l'app ne pourra pas utiliser Screen Time sur device réel. |
| `CFBundleDisplayName` | ✅ corrigé (`"FaithFocus"`) | — |
| `ITSAppUsesNonExemptEncryption` | ✅ ajouté (`<false/>`) | — |
| **`PrivacyInfo.xcprivacy` (Privacy Manifest)** | ✅ créé (`ios/Runner/PrivacyInfo.xcprivacy`) | Déclare l'usage de `UserDefaults` par `ScreenTimeManager` (raison `CA92.1`). **Reste à faire dans Xcode** : l'ajouter à la Target Membership de Runner (cf. `task6-ios-xcode-setup.md`, section 2bis) — impossible à vérifier sans macOS. |
| Icônes de lancement | ⚠️ icônes par défaut Flutter | Remplacer avant soumission. |
| Politique de confidentialité (URL) | ❌ absente | Requise par App Store Connect pour toute app demandant Screen Time / Family Controls (et par Google Play pour l'Accessibility API, cf. section 2). Hors périmètre du code — à rédiger et héberger avant soumission. |

---

## 2. Texte de justification — Google Play Console, formulaire "Accessibility API"

> À adapter selon la formulation exacte demandée par le formulaire au moment de la soumission.

```
FaithFocus est une application d'auto-discipline numérique ("Jeûne
Digital") qui aide l'utilisateur à limiter volontairement son usage
d'applications distrayantes pendant des plages horaires ou des durées
qu'il définit lui-même.

Usage du service d'accessibilité (BlockingAccessibilityService) :
Le service écoute exclusivement les événements TYPE_WINDOW_STATE_CHANGED
pour détecter quelle application est au premier plan. Cette information
est comparée localement à la liste d'applications que l'utilisateur a
lui-même choisi d'autoriser pendant sa session de blocage. Si l'application
au premier plan n'est pas autorisée et qu'une session est active, un écran
de rappel s'affiche par-dessus, invitant l'utilisateur à revenir à
l'essentiel ou à faire une courte leçon biblique.

Pourquoi le service d'accessibilité est nécessaire :
Android ne propose pas d'API publique standard permettant à une
application tierce de détecter en temps réel quelle application est au
premier plan et d'intervenir immédiatement. Le service d'accessibilité est
la seule API permettant ce niveau de réactivité, indispensable à la
fonctionnalité centrale de l'application (le blocage doit se déclencher
instantanément à l'ouverture d'une application non autorisée, pas après un
délai). Nous n'utilisons pas UsageStatsManager, qui ne fournit qu'un
historique consultable a posteriori et non un événement en temps réel.

Traitement des données :
- Le service ne lit ni n'interprète le contenu affiché par les autres
  applications (canRetrieveWindowContent est désactivé).
- Aucune donnée collectée par ce service (nom de l'application au premier
  plan) n'est transmise à un serveur tiers, à un service d'analytics ou à
  quelque destination que ce soit hors de l'appareil de l'utilisateur.
- La liste des applications autorisées par l'utilisateur est stockée
  localement, chiffrée (Android Jetpack Security / EncryptedSharedPreferences).
- L'utilisateur active et désactive ce service explicitement depuis les
  réglages d'accessibilité du système, et peut le désactiver à tout moment.
```

---

## 3. Tests manuels restants avant soumission

Les checklists détaillées existent déjà pour le blocage natif :
- `docs/manual-tests/task4-android-accessibility-blocking.md`
- `docs/manual-tests/task5-android-overlay.md`
- `docs/manual-tests/task6-ios-family-controls.md` (+ `task6-ios-xcode-setup.md`)

Ce qui reste, **au-delà** de ces checklists, avant soumission :

### Android

- [ ] Test d'installation propre (désinstaller/réinstaller) : vérifier qu'aucun état résiduel (whitelist, session) ne subsiste entre deux installations.
- [ ] Parcours complet : configuration d'une session (Tâche 7) → blocage effectif (Tâche 4/5) → leçon de quiz depuis le bouton de l'overlay (Tâche 8, actuellement seul le retour au premier plan est câblé, pas la navigation précise vers un quiz — à valider que ça ne plante pas).
- [ ] Test sur au moins un appareil d'un fabricant connu pour des restrictions agressives de gestion de batterie (Xiaomi/MIUI, Samsung, Huawei) : ces OEM tuent fréquemment les services d'arrière-plan/accessibilité de façon plus agressive que l'AOSP pur — impact direct sur la fiabilité du blocage.
- [ ] Test de la checklist Tâche 4/5 sur une version Android récente (14/15) en plus de l'émulateur API 28 déjà utilisé en développement.
- [ ] Vérification du comportement si l'utilisateur révoque la permission d'accessibilité *pendant* une session active.

### iOS

- [ ] L'intégralité de `task6-ios-family-controls.md`, qui n'a pas pu être exécutée dans cet environnement de développement (pas de macOS/Xcode disponible ici) — **priorité la plus haute avant toute soumission iOS**, y compris la validation de compilation elle-même.
- [ ] Confirmation que `com.apple.developer.family-controls` est bien approuvé par Apple sur le compte développeur utilisé pour la soumission.
- [ ] Test sur un appareil avec une session Focus configurée via `ManagedSettingsStore` puis mise en arrière-plan/redémarrage de l'app (pas seulement tuée) pour vérifier la persistance côté `DeviceActivityMonitorExtension`.
- [ ] Vérification visuelle réelle du Shield (couleurs, lisibilité) — non vérifiable sans device/Xcode dans cet environnement.

### Commun (Flutter, indépendant de la plateforme)

- [ ] Test des écrans de quiz (Tâche 8) et du classement (Tâche 9) avec Firestore réellement connecté — actuellement testés uniquement avec des données locales en dur / mocks (cf. section 4, aucune intégration Firestore client n'existe encore).
- [ ] Test d'accessibilité de l'app elle-même (contraste, taille de police, lecteurs d'écran) — non couvert par les tâches précédentes.

---

## 4. TODO techniques en suspens

Compilation de tous les TODO/limitations signalés au fil des tâches, plus une découverte transverse importante :

### 🔴 Écart le plus significatif : pas d'authentification Firebase implémentée

`AuthService` (Tâche 1) est resté un stub vide. Aucun écran de connexion/
inscription n'existe, et rien côté Flutter n'appelle
`FirebaseAuth`. Conséquence concrète : tout le modèle de sécurité construit
aux Tâches 2 et 9 (Firestore Security Rules basées sur `request.auth.uid`,
Cloud Function `submitLessonResult` qui vérifie `context.auth`) est
correct **mais actuellement inatteignable depuis l'app** — il n'y a pas
encore de session utilisateur pour l'invoquer. C'est probablement la
prochaine brique critique, avant même de pouvoir tester Tâche 9
end-to-end.

### Autres TODO par tâche

- **Tâche 1** : pas de `google-services.json`/`GoogleService-Info.plist`
  (attendu — fichiers spécifiques au projet Firebase du client, à fournir
  hors dépôt versionné) ; aucun adaptateur Hive enregistré (aucune box
  n'est encore utilisée).
- **Tâche 4 (Android)** : `PACKAGE_USAGE_STATS` déclarée mais inutilisée
  (cf. section 1) ; `requestPermissions()` ne peut pas attendre
  synchroniquement le retour des écrans système.
- **Tâche 5 (Android)** : démarrage du service overlay depuis un contexte
  d'accessibilité non vérifié vis-à-vis des restrictions Android 8+ (cf.
  section 1) ; réglages visuels de `WindowManager` (zone barre de statut)
  non affinés.
- **Tâche 6 (iOS)** : **aucune compilation réelle vérifiée** (pas de macOS
  dans cet environnement) ; entitlement Family Controls à faire approuver
  par Apple ; `DeviceActivitySchedule` peu fiable pour des sessions
  chevauchant minuit ; whitelist stockée en clair via `UserDefaults` (pas
  chiffrée, contrairement à Android — écart OWASP M9, cf. section 5) ;
  "FaithFocus non décochable" dans le picker non applicable techniquement
  (limite Apple) ; `PrivacyInfo.xcprivacy` manquant (cf. section 1).
- **Tâche 7** : whitelist de l'app biblique en texte libre plutôt qu'un
  vrai picker natif Android ; pas d'écran d'accueil/onboarding, l'app
  démarre directement sur le mode Focus.
- **Tâche 8** : `LessonScreen` n'est reliée à aucune navigation depuis le
  reste de l'app ; aucune donnée Firestore réelle, uniquement le jeu de
  données en dur.
- **Tâche 9** : `LeaderboardScreen` et `streak_calculator` ne sont
  connectés à aucune source de données réelle (pas de repository
  Firestore) ; **surtout : rien côté Flutter n'appelle la Cloud Function
  `submitLessonResult`** après une leçon complétée dans `LessonScreen` — le
  résultat calculé localement (Tâche 8) n'est aujourd'hui jamais envoyé au
  serveur. `SyncService` (Tâche 1) reste un stub vide.

---

## 5. Revue de conformité OWASP transverse

| Contrainte | Statut | Fichiers concernés |
|---|---|---|
| **M9 — Stockage local chiffré** | 🟡 Partiellement respecté | Android : `FocusSessionStore.kt` (EncryptedSharedPreferences) — ✅ respecté. iOS : `ScreenTimeManager.swift` stocke `FamilyActivitySelection` via `UserDefaults(suiteName:)` **non chiffré** — ⚠️ écart à corriger avant production (ex. chiffrement applicatif de la donnée avant stockage, ou acceptation du risque documentée — la donnée reste sandboxée à l'App Group, mais n'est pas chiffrée au repos). Dart/Hive : aucune box sensible implémentée à ce stade — rien à auditer, le mécanisme `HiveAesCipher` prévu en Tâche 1 reste à mettre en place quand une telle box existera. |
| **M9 — Pas de logs en clair (tokens, whitelist)** | ✅ Respecté | Aucun `print`/log de token, uid complet ou whitelist trouvé dans le code natif ou Dart. |
| **M3/API1 — Auth sur les Cloud Functions** | ✅ Respecté (côté serveur) | `functions/src/submitLessonResult.ts` : rejette tout appel sans `context.auth` ou avec `userId` ne correspondant pas à `context.auth.uid`. **Non exploitable en pratique tant que l'auth Flutter n'existe pas** (cf. section 4). |
| **API5 — Security Rules par propriétaire** | ✅ Respecté | `firestore.rules` : `/users/{userId}/progress`, `/users/{userId}/attempts` bornés à `request.auth.uid == userId` ; `/leaderboards` et `/questions` en lecture seule côté client. |
| **M4/API3 — Validation des entrées (Method Channel)** | ✅ Respecté | Dart : `validateFocusSessionArgs` (`app_blocker_channel.dart`). Natif : revalidation en profondeur dans `AppBlockerPlugin.kt` (Android) et `AppBlockerPlugin.swift` (iOS) — défense en profondeur, ne fait pas confiance à la seule validation Dart. |
| **M4/API3 — Score de quiz jamais fait confiance côté client** | ✅ Respecté | `functions/src/answerValidation.ts` revalide chaque réponse contre `/questions/{id}` ; `submitLessonResult.ts` ignore tout score envoyé par le client. |
| **M5 — Communications chiffrées** | ✅ Respecté | Aucun `usesCleartextTraffic="true"` dans `AndroidManifest.xml` ; aucune exception App Transport Security dans `Info.plist` ; SDK Firebase utilisé sans configuration TLS custom. |
| **M6 — Minimisation des données / whitelist jamais envoyée à un tiers** | ✅ Respecté | Aucun SDK d'analytics/publicité intégré ; whitelist stockée localement uniquement (Android chiffré, iOS via App Group — cf. écart M9 ci-dessus) ; `displayName` du leaderboard dérivé du claim d'auth, jamais d'un champ libre du payload (anti-usurpation, `submitLessonResult.ts`). |
| **API4 — Anti-spam / rate limiting** | ✅ Respecté | `submitLessonResult.ts` : rejet si moins de 15s depuis `lastSubmissionServerTime` (horodatage serveur, jamais client) ; protection anti-rejeu par `attemptId` idempotent. |
| **M8 — Pas de secret en dur** | ✅ Respecté | Aucune clé API/credential trouvée en dur dans le code source Dart/Kotlin/Swift/TypeScript. `google-services.json`/`GoogleService-Info.plist` délibérément absents du dépôt (à fournir par le client hors versionnement). |

### Synthèse

Sur les 9 contrôles audités : **7 pleinement respectés**, **1 partiellement
respecté** (chiffrement du stockage local iOS, à corriger), et **1
respecté en conception mais non exploitable en pratique** faute
d'authentification Flutter implémentée (auth/autorisation serveur). Aucune
violation active identifiée — les deux réserves sont des lacunes
d'intégration, pas des failles de sécurité déjà exploitables en l'état
actuel (puisque les fonctionnalités correspondantes ne sont pas encore
branchées de bout en bout).
