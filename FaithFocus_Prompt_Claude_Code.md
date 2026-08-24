# Prompt Claude Code — Projet FaithFocus

> Copiez ce prompt (en entier, ou tâche par tâche) dans Claude Code. Il est conçu pour être exécuté séquentiellement : chaque tâche suppose que la précédente est terminée et validée. Ne pas tout envoyer d'un coup sur un premier projet — avancer tâche par tâche permet à Claude Code de produire du code testable à chaque étape plutôt qu'un gros bloc invérifiable.

---

## Contexte à coller en tête de la conversation Claude Code (une seule fois)

```
Je développe "FaithFocus", une application mobile Flutter destinée aux chrétiens,
qui combine :
1. Un "Jeûne Digital" : blocage natif des apps du téléphone pendant une plage
   horaire ou un minuteur défini, avec une whitelist (FaithFocus + une app
   biblique tierce type YouVersion).
2. Un module de quiz bibliques gamifié façon Duolingo (leçons, XP, streaks,
   classement entre amis).

Stack : Flutter (Dart) pour le cross-platform, Kotlin pour les modules natifs
Android (AccessibilityService, UsageStatsManager, overlay), Swift pour les
modules natifs iOS (FamilyControls, DeviceActivity, ManagedSettings).
Backend : Firebase (Firestore, Auth, Cloud Functions, FCM).
State management : Riverpod. Stockage local offline-first : Hive.

Je vais te donner les tâches une par une. Pour chaque tâche :
- Pose-moi des questions si un choix d'implémentation n'est pas précisé plutôt
  que de supposer.
- Écris du code idiomatique, testable, avec gestion d'erreurs explicite.
- N'implémente que ce qui est demandé dans la tâche en cours ; ne code pas en
  avance sur les tâches suivantes.
- Ajoute des commentaires uniquement là où la logique n'est pas évidente
  (permissions système, workarounds spécifiques à une plateforme, etc.).
- À la fin de chaque tâche, résume en 3-4 lignes ce qui a été fait et liste
  les éventuels TODO ou limitations connues.
```

---

## Contraintes de sécurité transverses (OWASP) — à coller aussi en tête, valables pour TOUTES les tâches

```
Applique en permanence les contraintes de sécurité suivantes, basées sur
l'OWASP Mobile Application Security (MASVS/Mobile Top 10) et l'OWASP API
Security Top 10. Si une tâche entre en tension avec l'une de ces règles,
signale-le explicitement au lieu de l'ignorer silencieusement.

Stockage et données locales (réf. OWASP Mobile M9 — Insecure Data Storage) :
- Aucune donnée sensible (token d'auth, identifiant de session Focus,
  historique de blocage) ne doit être stockée en clair. Utilise Hive avec
  chiffrement (HiveAesCipher) pour toute box contenant autre chose que du
  contenu public (leçons, questions).
- Ne jamais logger de token, d'identifiant utilisateur complet ou de contenu
  de whitelist en clair, même en mode debug (utilise un masquage systématique
  dans les logs).

Authentification et autorisation (réf. OWASP Mobile M3 / API1 & API5 —
Broken Object & Function Level Authorization) :
- Toute Cloud Function doit vérifier `context.auth` avant tout traitement et
  rejeter explicitement les appels non authentifiés.
- Toute lecture/écriture Firestore doit passer par des Security Rules qui
  vérifient que `request.auth.uid` correspond au propriétaire de la
  ressource (un utilisateur ne doit jamais pouvoir modifier le UserProgress
  ou le score d'un autre utilisateur).
- Le leaderboard doit être une vue en lecture seule pour les clients ; seule
  la Cloud Function peut écrire les scores agrégés.

Validation des entrées (réf. OWASP Mobile M4 / API3 — Improper Input
Validation) :
- Toute donnée reçue via Method Channel, Firestore, ou payload de Cloud
  Function doit être validée en type et en plage de valeurs avant usage
  (ex : timerSeconds ne doit pas être négatif ou démesuré, whitelist ne doit
  pas contenir de chaînes vides ou de tailles excessives).
- Les réponses de quiz envoyées à la Cloud Function ne doivent jamais servir
  de source de vérité pour le score : seule la comparaison serveur avec les
  `correctOptionIndexes` stockés côté backend fait foi.

Communications réseau (réf. OWASP Mobile M5 — Insecure Communication) :
- Toute communication avec Firebase doit passer par HTTPS/TLS (par défaut
  avec le SDK, mais vérifie qu'aucune configuration ne désactive la
  validation de certificat, y compris en debug).
- N'ajoute aucun `usesCleartextTraffic="true"` dans AndroidManifest.xml ni
  équivalent iOS (App Transport Security) sans justification explicite.

Confidentialité et minimisation des données (réf. OWASP Mobile M6 —
Inadequate Privacy Controls, pertinent aussi car public potentiellement
mineur) :
- Ne collecte que les données strictement nécessaires (pas de tracking
  publicitaire, pas de géolocalisation).
- Le contenu de la whitelist (apps choisies par l'utilisateur) est une
  donnée potentiellement sensible sur les habitudes de la personne : elle ne
  doit jamais être envoyée à un service tiers ni incluse dans des logs
  d'analytics.

Surface d'attaque des Cloud Functions (réf. OWASP API4 — Unrestricted
Resource Consumption) :
- Ajoute une limite de fréquence (rate limiting applicatif, ex : vérifier
  `lastActivityDate` avant d'accepter une soumission) sur
  submitLessonResult pour empêcher un utilisateur de spammer l'endpoint et
  de gonfler artificiellement son XP/streak.

Configuration et secrets (réf. OWASP Mobile M8 — Security Misconfiguration) :
- Aucune clé API, credential Firebase Admin, ou secret ne doit apparaître en
  dur dans le code source Dart/Kotlin/Swift/TypeScript. Utilise les
  mécanismes prévus (google-services.json / GoogleService-Info.plist hors
  du code versionné si sensible, variables d'environnement pour les Cloud
  Functions).
- Signale-moi explicitement si une tâche nécessiterait d'introduire un
  secret en dur, plutôt que de le faire.

Pour chaque tâche impliquant une Cloud Function, une Security Rule Firestore,
ou une manipulation de données utilisateur, ajoute une brève section
"Sécurité" à la fin de ton résumé listant les contrôles OWASP appliqués.
```

---

## Contraintes de design UI — à coller aussi en tête, valables pour TOUTES les tâches produisant de l'UI

```
Applique ces contraintes visuelles à tout écran ou composant UI produit dans
ce projet (Flutter, Jetpack Compose Android, SwiftUI/UIKit iOS) :

- Aucun dégradé de couleur (linear-gradient, gradient Skia/Canvas, gradient
  Compose Brush, etc.), sauf si je le demande explicitement pour un cas
  précis. Toutes les surfaces (fonds, boutons, cartes, barres de progression)
  sont en couleur plate (flat design).
- Définis une palette de couleurs fixe et restreinte dès la Tâche 1, dans un
  fichier centralisé (ex: lib/core/theme/app_colors.dart + un ColorScheme
  Material 3 associé) :
  - 1 couleur primaire, 1 couleur d'accent secondaire,
  - une échelle de gris/neutres pour texte et fonds (au moins 4 nuances :
    fond, surface, texte secondaire, texte principal),
  - des couleurs sémantiques minimales : succès (validation quiz), erreur
    (mauvaise réponse), pas plus.
  Toute couleur utilisée dans une tâche suivante doit provenir de cette
  palette — jamais de couleur hexadécimale ad hoc écrite en dur dans un
  widget ou un layout XML/Compose.
- Pas d'ombres portées prononcées, pas d'effet néon/glow, pas de flou
  décoratif (backdrop blur en dehors de l'usage système imposé par
  ShieldConfiguration sur iOS, qui n'est pas négociable). Élévations
  discrètes uniquement (tonal elevation Material 3 ou équivalent simple).
- Une seule famille de police pour tout le projet, 2 graisses maximum
  (regular + medium/semibold). Pas de police décorative.
- Si une tâche nécessiterait une couleur, un dégradé ou un style visuel non
  prévu par la palette initiale, arrête-toi et demande-moi confirmation
  plutôt que d'improviser une variante.
```

---

## Tâche 1 — Scaffolding du projet et architecture de dossiers

```
Crée la structure de projet Flutter suivante, avec les fichiers vides ou
minimalement stubés nécessaires pour qu'elle compile :

lib/
├── core/
│   ├── platform/       (wrappers Method Channel)
│   ├── services/       (AuthService, SyncService, NotificationService)
│   └── models/         (data models partagés)
├── features/
│   ├── focus_mode/
│   ├── quiz/
│   ├── gamification/
│   └── onboarding/
└── main.dart

Configure Riverpod (ProviderScope) et Hive (initFlutter + registerAdapter
stub) dans main.dart. Ajoute les dépendances nécessaires dans pubspec.yaml
(riverpod, hive, hive_flutter, firebase_core, firebase_auth, cloud_firestore).
Ne code aucune logique métier pour l'instant, uniquement le squelette.

Crée aussi lib/core/theme/app_colors.dart et lib/core/theme/app_theme.dart :
définis la palette de couleurs plates décrite dans la section "Contraintes
de design UI" (couleur primaire, accent, échelle de neutres, succès/erreur),
construis un ColorScheme Material 3 à partir de cette palette, et applique-le
dans le MaterialApp de main.dart. Aucune autre couleur ne doit être
introduite ailleurs dans le projet sans passer par ce fichier.
```

---

## Tâche 2 — Modèles de données du module Quiz

```
Implémente en Dart, dans lib/core/models/quiz_models.dart, les classes
suivantes : BibleModule, Lesson, Question (avec enum QuestionType :
multipleChoice, trueFalse, fillInBlank, matchPairs, orderSequence),
UserProgress, LessonProgress, LeaderboardEntry.

Contraintes :
- Toutes les classes doivent être immuables (final fields, const constructors
  quand possible).
- Ajoute les méthodes fromJson / toJson pour chaque modèle (sérialisation
  Firestore).
- Ajoute des tests unitaires simples vérifiant la sérialisation/désérialisation
  round-trip pour chaque modèle.
- UserProgress doit exposer un getter currentLevel calculé à partir de totalXp
  (seuils de 500 XP par niveau, mais rends cette valeur configurable via une
  constante en haut du fichier).

Rédige aussi un premier jet des Firestore Security Rules pour les
collections /users/{userId}/progress et /leaderboards, en appliquant les
contraintes de la section "Sécurité transverse" (un utilisateur ne peut lire/
écrire que son propre UserProgress, le leaderboard est en lecture seule côté
client).
```

---

## Tâche 3 — Method Channel côté Dart (interface commune)

```
Crée lib/core/platform/app_blocker_channel.dart avec une classe
AppBlockerChannel exposant :
- Future<bool> requestPermissions()
- Future<void> startFocusSession({required List<String> whitelistedPackageIds,
  DateTime? scheduledStart, DateTime? scheduledEnd, Duration? timerDuration})
- Future<void> stopFocusSession()
- Stream<String> get onBlockedAppAttempt (via EventChannel)

Utilise MethodChannel('com.faithfocus/blocker') et
EventChannel('com.faithfocus/blocker_events').

Crée aussi une classe FakeAppBlockerChannel qui implémente la même interface
sans appeler de code natif (retourne des valeurs simulées), pour permettre
de développer et tester l'UI Flutter du mode Focus sans dépendre du natif
tout de suite. Utilise cette interface commune (classe abstraite ou pattern
Provider Riverpod overridable) pour que je puisse basculer facilement entre
la vraie implémentation et la fake en debug.
```

---

## Tâche 4 — Module natif Android : permissions et service d'accessibilité

```
Implémente côté Android (Kotlin) :

1. AppBlockerPlugin.kt : reçoit les appels du MethodChannel
   "com.faithfocus/blocker" et gère "requestPermissions",
   "startFocusSession", "stopFocusSession".
2. BlockingAccessibilityService.kt : AccessibilityService qui détecte
   TYPE_WINDOW_STATE_CHANGED, compare le package ouvert à une whitelist
   stockée localement de façon chiffrée (EncryptedSharedPreferences via
   Jetpack Security, pas de SharedPreferences en clair — cf. contrainte
   OWASP M9 sur le stockage local), et déclenche un événement vers Flutter +
   l'affichage d'un overlay si l'app n'est pas whitelistée et qu'une session
   Focus est active.
3. Le fichier accessibility_service_config.xml associé.
4. Les permissions nécessaires dans AndroidManifest.xml (PACKAGE_USAGE_STATS,
   SYSTEM_ALERT_WINDOW, déclaration du service).

Gère explicitement les cas suivants :
- Permissions non accordées : requestPermissions doit rediriger vers les
  bons écrans de paramètres système et retourner false si tout n'est pas
  accordé.
- Session Focus qui n'est plus active (fin d'horaire ou timer écoulé) :
  le service doit arrêter de bloquer automatiquement, pas seulement sur
  appel explicite de stopFocusSession.

Écris aussi un test manuel étape par étape (checklist) que je pourrai suivre
sur un appareil physique pour valider que le blocage fonctionne, car ce type
de service ne se teste pas bien en test unitaire classique.
```

---

## Tâche 5 — Overlay natif Android (écran de verrouillage ludique)

```
Implémente OverlayLockScreenService.kt : un service qui affiche une
fenêtre système (TYPE_APPLICATION_OVERLAY) par-dessus l'app bloquée,
avec :
- Un message motivant, pioché aléatoirement (jamais deux fois de suite
  identique) dans une banque d'au moins 4 catégories de ton : recentrage
  doux, invitation, neutre/factuel, curiosité. Écris au moins 3 messages
  par catégorie, dans l'esprit "Reviens à l'essentiel" plutôt que
  culpabilisant (jamais de tournure du type "tu as encore craqué").
- Le nom lisible de l'app détectée, affiché dans le titre
  ("{NomApp} est en pause").
- Le temps restant de la session Focus, mis à jour au minimum chaque
  minute.
- Un bouton "Faire un quiz de 3 minutes" qui ferme l'overlay et ouvre
  FaithFocus directement sur un quiz aléatoire non complété.
- Un bouton secondaire "Retour à l'accueil" qui ramène à l'écran d'accueil
  du téléphone (Intent.ACTION_MAIN / CATEGORY_HOME) plutôt que de laisser
  l'app bloquée en arrière-plan.

Comportement explicite à respecter : l'overlay ne doit JAMAIS se fermer
automatiquement après un délai, même si l'utilisateur reste inactif. Il ne
se ferme que sur une action explicite (quiz ou accueil) — sinon le
mécanisme perd tout son sens puisqu'il suffirait d'attendre.

Le layout doit être en Jetpack Compose si le projet le permet, sinon en
XML classique — dis-moi lequel tu choisis et pourquoi avant de coder.
Respecte la contrainte de design transverse : couleurs plates uniquement
issues de app_colors.dart / du ColorScheme équivalent côté Android natif
(exporte les mêmes valeurs de couleur côté Kotlin, ex. via un fichier
colors.xml généré ou synchronisé manuellement), aucun dégradé.
```

---

## Tâche 6 — Module natif iOS : FamilyControls et DeviceActivity

```
Implémente côté iOS (Swift) :

1. ScreenTimeManager.swift : requestAuthorization(), applyShield(selection:),
   startSchedule(start:end:), removeShield(), en utilisant FamilyControls,
   ManagedSettings, DeviceActivity.
2. Une target d'extension DeviceActivityMonitorExtension avec
   MonitorExtension.swift qui active/désactive le shield sur
   intervalDidStart / intervalDidEnd.
3. Le handler MethodChannel côté AppDelegate.swift (ou un plugin Flutter
   dédié) qui relie "com.faithfocus/blocker" à ScreenTimeManager.

Explique-moi, avant de commencer à coder, comment tu comptes gérer le fait
qu'Apple impose un FamilyActivityPicker natif pour la sélection des apps
(je ne peux pas lister les apps installées par code) — je veux valider
l'approche UX avant que tu l'implémentes.

Ajoute aussi un ShieldConfigurationExtension et un ShieldActionExtension
minimaux. Respecte les limites réelles d'Apple avant de proposer une UX
irréaliste :
- Titre et sous-titre du Shield sont des textes STATIQUES (pas de compteur
  en direct injecté dynamiquement).
- Une seule icône/couleur pour tout le Shield, pas d'icône par app bloquée.
- Deux boutons maximum ; l'action de chacun est gérée par
  ShieldActionExtension, pas par un deep link direct pendant l'affichage —
  au clic sur "Faire un quiz", ouvre FaithFocus via une URL scheme custom
  (ex. faithfocus://quiz/random) plutôt que de tenter une navigation en
  place. Le bouton "Retour à l'accueil" doit simplement fermer le Shield
  (ShieldActionResponse.close).
Utilise uniquement les couleurs de la palette définie en Tâche 1 pour la
configuration du Shield (backgroundColor, couleurs de bouton) — pas de
dégradé, pas de couleur choisie librement par toi.
```

---

## Tâche 7 — UI du Mode Focus (Flutter)

```
Implémente dans lib/features/focus_mode/ :
- Un écran de configuration permettant de choisir entre "plage horaire" et
  "minuteur", avec sélection de la whitelist (au moins FaithFocus +
  un slot pour une app biblique).
- Un écran "session active" affichant le temps restant, avec un design
  apaisant (cohérent avec un contexte de recueillement), en utilisant
  exclusivement les couleurs de app_colors.dart — aucune couleur ad hoc,
  aucun dégradé.
- La connexion à AppBlockerChannel (utilise le Provider Riverpod pour
  basculer entre Fake et vraie implémentation selon le flavor de build).

Utilise Riverpod pour l'état de la session (StateNotifier ou AsyncNotifier).
Ajoute des tests widget pour l'écran de configuration.
```

---

## Tâche 8 — Moteur de Quiz et UI (Flutter)

```
Implémente dans lib/features/quiz/ :
- Un QuizEngine (classe pure Dart, sans dépendance UI) qui prend une liste
  de Question, gère la progression, calcule le score et l'XP gagné selon
  le nombre de bonnes réponses et la difficulté.
- L'écran de leçon : affichage d'une question à la fois, feedback immédiat
  correct/incorrect avec l'explication, barre de progression en haut,
  animation de célébration (confettis ou équivalent) à la complétion.
  Utilise exclusivement les couleurs de app_colors.dart (succès/erreur
  compris) — aucune couleur en dur, aucun dégradé même pour la barre de
  progression.
- Écris le QuizEngine de façon testable en isolation (tests unitaires sur
  le calcul de score/XP pour chaque QuestionType).

N'implémente pas encore la synchronisation Firestore, uniquement la logique
locale avec des données de test en dur (au moins 2 modules, 3 leçons, 10
questions variées).
```

---

## Tâche 9 — Gamification : Streaks et Leaderboard

```
Implémente lib/features/gamification/ :
- Le calcul du streak côté Dart pour l'affichage local optimiste
  (utilitaire pur, testable) à partir d'un historique de dates d'activité —
  étiquette-le clairement comme un affichage optimiste en attendant la
  confirmation serveur, jamais comme la source de vérité.
- L'écran de classement (Leaderboard) affichant une liste de
  LeaderboardEntry avec le rang de l'utilisateur mis en évidence. Utilise
  uniquement les couleurs de la palette définie en Tâche 1.

Puis crée la Cloud Function TypeScript (functions/src/submitLessonResult.ts)
qui, dans une transaction Firestore :
1. Vérifie context.auth et rejette tout appel non authentifié ou dont
   payload.userId ne correspond pas à context.auth.uid (réf. OWASP API1).
2. Valide strictement le format de SubmitLessonResultPayload (types, tailles
   de tableaux bornées, IDs existants) avant tout traitement.
3. Applique une protection anti-rejeu (idempotency) : dérive un identifiant
   de tentative (ex. lessonId + clientTimestamp) et vérifie dans
   /users/{uid}/attempts/{attemptId} qu'elle n'a pas déjà été traitée ;
   sinon rejette avec un code "already-exists".
4. Applique un anti-spam basé sur un timestamp SERVEUR
   (admin.firestore.Timestamp.now(), jamais une date envoyée par le client)
   comparé au dernier lastSubmissionServerTime stocké : rejette si moins de
   15 secondes se sont écoulées (une leçon de 3 min ne peut légitimement pas
   être complétée plus vite).
5. Revalide les réponses côté serveur en comparant aux correctOptionIndexes
   stockés dans /questions/{id} (ne fait jamais confiance au score envoyé
   par le client).
6. Calcule le nouveau streak à partir de lastActivityDate stocké côté
   serveur comparé à l'horodatage serveur actuel — jamais à partir d'une
   date envoyée par le client, pour neutraliser la manipulation de
   l'horloge locale du téléphone.
7. Met à jour totalXp, currentStreakDays, longestStreakDays dans Firestore
   au sein de la même transaction que l'écriture de l'attemptId.

Crée ensuite une seconde Cloud Function planifiée
(functions/src/recomputeWeeklyLeaderboard.ts, Pub/Sub schedule toutes les
15 minutes) qui agrège les scores de la semaine et réécrit
/leaderboards/weekly/* en une seule passe — n'écris jamais le leaderboard
au fil de l'eau à chaque soumission individuelle, pour éviter les
conditions de course entre soumissions simultanées et limiter les lectures
Firestore.

Explique dans un commentaire en haut de chaque fichier pourquoi cette
validation doit être serveur et non client, et ajoute en fin de tâche la
section "Sécurité" résumant les contrôles OWASP appliqués (y compris la
protection anti-rejeu et l'usage exclusif de l'horodatage serveur).
```

---

## Tâche 10 — Intégration finale et checklist de publication

```
Fais une revue de l'ensemble du projet et :
1. Liste les permissions/déclarations manquantes ou incomplètes dans
   Info.plist et AndroidManifest.xml pour la soumission aux stores.
2. Rédige un texte de justification (en français) pour la Play Console
   expliquant l'usage du service d'accessibilité, à adapter et coller
   dans le formulaire "Accessibility API" de Google Play.
3. Liste les tests manuels restants à faire sur device physique avant
   soumission (Android ET iOS séparément, vu l'asymétrie du blocage).
4. Signale tout TODO technique laissé en suspens dans les tâches précédentes.
5. Fais une revue de conformité OWASP sur l'ensemble du projet : passe en
   revue chaque contrainte listée dans la section "Contraintes de sécurité
   transverses" et indique, pour chacune, si elle est respectée, partiellement
   respectée, ou non traitée — avec le fichier concerné dans chaque cas.
```

---

## Notes d'usage

- Si Claude Code propose une architecture différente de celle du dossier
  technique de référence, demandez-lui de justifier l'écart avant d'accepter.
- Pour les tâches 4 et 6 (code natif sensible), demandez systématiquement une
  checklist de test manuel sur device réel — ce type de fonctionnalité ne se
  valide pas de manière fiable en simulateur/émulateur.
- Gardez la tâche 10 pour la fin même si vous itérez sur les tâches 1 à 9 en
  parallèle sur plusieurs sessions.
