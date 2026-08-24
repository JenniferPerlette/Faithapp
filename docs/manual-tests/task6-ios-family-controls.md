# Checklist de test manuel — Tâche 6 (blocage natif iOS)

Prérequis : suivre d'abord `task6-ios-xcode-setup.md` (targets d'extension
créées, entitlements en place, build réussi). À exécuter sur un **device
iOS physique** — `FamilyControls`/`ManagedSettings` ne fonctionnent pas de
façon fiable en simulateur.

## 1. Autorisation Temps d'écran

1. Appeler `requestPermissions()` depuis l'app (bouton de debug temporaire).
   - [ ] Une pop-up système "FaithFocus souhaite utiliser Temps d'écran"
     apparaît.
   - [ ] Accepter → la méthode retourne `true`.
   - [ ] Refuser (sur un second essai, après avoir révoqué dans
     Réglages > Temps d'écran) → retourne `false`.

## 2. Sélection de la whitelist

1. Appeler `presentFamilyActivityPicker()`.
   - [ ] Le picker système Apple s'ouvre en plein écran, avec le texte
     d'avertissement ("Gardez FaithFocus et votre app biblique cochées…")
     visible au-dessus.
2. Cocher FaithFocus + une app tierce, valider.
   - [ ] Le résumé affiche les icônes des apps choisies (via `Label`), pas
     de nom en clair dans les logs Xcode.
   - [ ] `getWhitelistSelectionCount()` retourne le bon nombre.
3. Rouvrir le picker sans rien changer.
   - [ ] La sélection précédente est pré-remplie (pas de perte au
     redémarrage de l'app).

## 3. Refus de session avec whitelist vide

1. Sur un compte/app fraîchement installé (aucune sélection faite), appeler
   `startFocusSession(...)`.
   - [ ] La méthode échoue avec le code d'erreur `empty_whitelist`, pas de
     shield appliqué.

## 4. Session par minuteur — blocage effectif

1. Sélectionner une whitelist (FaithFocus + 1 app), démarrer une session
   avec `timerDuration: Duration(minutes: 2)`.
2. Ouvrir une app **non** whitelistée.
   - [ ] Le Shield système apparaît immédiatement, plein écran.
   - [ ] Le titre affiche "{Nom de l'app} est en pause".
   - [ ] Couleurs : fond, textes et boutons correspondent à la palette
     FaithFocus (`FaithFocusColors`) — pas de dégradé, pas d'icône par app.
3. Ouvrir l'app whitelistée (l'app tierce cochée).
   - [ ] Aucun Shield ne s'affiche.

## 5. Boutons du Shield

1. Depuis un Shield affiché, taper "Faire un quiz de 3 minutes".
   - [ ] Le Shield se ferme.
   - [ ] FaithFocus revient au premier plan (deep link
     `faithfocus://quiz/random` reçu — vérifier en breakpoint dans
     `AppDelegate.application(_:open:options:)`, la navigation réelle vers
     un quiz n'est pas encore câblée, cf. TODO Tâche 8).
2. Rouvrir l'app bloquée, taper "Retour à l'accueil".
   - [ ] Le Shield se ferme et l'écran d'accueil du téléphone s'affiche
     (pas l'app bloquée en arrière-plan).

## 6. Fin de session automatique

1. Laisser le minuteur de 2 minutes expirer sans appeler
   `stopFocusSession()`.
2. Ouvrir l'app précédemment bloquée juste après expiration.
   - [ ] Plus aucun Shield ne s'affiche : `MonitorExtension.intervalDidEnd`
     a retiré le shield automatiquement.

## 7. Modification de la whitelist pendant une session active

1. Démarrer une session, puis appeler `presentFamilyActivityPicker()`
   pendant qu'elle est active.
   - [ ] Échoue avec le code d'erreur `session_active`, le picker ne
     s'ouvre pas.

## 8. Redémarrage de l'app pendant une session

1. Démarrer une session par minuteur de 10 minutes, tuer complètement le
   process FaithFocus.
2. Ouvrir une app non whitelistée.
   - [ ] Le Shield s'affiche quand même : le blocage est géré par
     `MonitorExtension`/`ManagedSettingsStore`, indépendamment du process
     principal (même garantie que côté Android, Tâche 4).

## Limitations connues à garder en tête pendant les tests

- `onBlockedAppAttempt` (EventChannel Dart) n'émettra jamais rien sur iOS :
  aucune notification en temps réel du process principal n'est possible
  quand le Shield d'une extension système s'affiche (asymétrie assumée
  avec Android, documentée dans `AppBlockerPlugin.swift`).
- Le bouton "Faire un quiz" ne route pas encore vers un quiz précis (Tâche
  8 non implémentée) : seul le retour au premier plan de l'app est câblé.
- Sessions chevauchant minuit : non fiables (`DeviceActivitySchedule`
  raisonne en heure du jour, pas en date absolue — cf.
  `AppBlockerPlugin.swift`).
- "FaithFocus non décochable" dans le picker n'est **pas** appliqué
  techniquement (limite Apple, cf. Tâche 6) : seul un texte d'avertissement
  et le refus de session à whitelist vide protègent contre l'auto-blocage.
