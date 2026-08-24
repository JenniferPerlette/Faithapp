# Checklist de test manuel — Tâche 4 (blocage natif Android)

Ce module (permissions spéciales + `AccessibilityService`) ne se valide pas
de façon fiable en test unitaire : à exécuter sur un **appareil physique**
(ou un émulateur avec Play Services, ex. `emulator-5554` / Android 9 déjà
connecté). Prérequis : `flutter run` en mode debug, whitelist de test =
`[applicationId de FaithFocus]`.

## 1. Permissions non accordées

1. Appareil neuf (aucune permission accordée) : appeler `requestPermissions()`
   depuis l'app (ex. bouton de debug temporaire).
   - [ ] La méthode retourne `false`.
   - [ ] L'écran système "Autoriser l'affichage par-dessus d'autres
     applications" s'ouvre (`SYSTEM_ALERT_WINDOW` manquante en premier).
2. Accorder l'autorisation d'overlay, revenir dans l'app, rappeler
   `requestPermissions()`.
   - [ ] Retourne toujours `false`.
   - [ ] L'écran des paramètres d'accessibilité s'ouvre cette fois
     (`Réglages > Accessibilité`).
3. Activer manuellement le service "FaithFocus" dans la liste des services
   d'accessibilité, revenir dans l'app, rappeler `requestPermissions()`.
   - [ ] Retourne `true`.

## 2. Session par minuteur — blocage effectif

1. Démarrer une session Focus avec `timerDuration: Duration(minutes: 2)` et
   une whitelist ne contenant **pas** le package d'une app tierce installée
   (ex. navigateur, réseau social).
2. Ouvrir cette app tierce non whitelistée dans les 2 minutes.
   - [ ] `onBlockedAppAttempt` émet le nom de package de l'app tierce côté
     Dart (vérifier via un `print`/log temporaire, jamais en clair en
     production — cf. contrainte OWASP sur les logs).
   - [ ] Le service `OverlayLockScreenService` est démarré et affiche
     l'overlay plein écran (cf. checklist dédiée
     `task5-android-overlay.md` pour le détail de son contenu).
3. Ouvrir FaithFocus (app whitelistée) pendant la session.
   - [ ] Aucun événement de blocage n'est émis.
4. Ouvrir l'app tierce une seconde fois immédiatement après (même session).
   - [ ] Un seul événement est émis pour cette "visite" (pas de spam à
     chaque micro-événement d'accessibilité).

## 3. Fin de session automatique

1. Démarrer une session avec `timerDuration: Duration(seconds: 30)`.
2. Attendre l'expiration du minuteur **sans** appeler `stopFocusSession()`.
3. Ouvrir l'app tierce non whitelistée juste après expiration.
   - [ ] Aucun événement de blocage n'est émis : le service détecte que
     `FocusSessionStore.isSessionActive()` est redevenu `false` sans action
     explicite.

## 4. Session par plage horaire

1. Démarrer une session avec `scheduledStart` = maintenant, `scheduledEnd` =
   dans 2 minutes.
2. Répéter les vérifications de la section 2 (blocage actif) puis de la
   section 3 (fin automatique après `scheduledEnd`).
   - [ ] Comportement identique au cas "minuteur".

## 5. Arrêt explicite

1. Démarrer une session par minuteur de 10 minutes.
2. Appeler `stopFocusSession()` immédiatement.
3. Ouvrir l'app tierce non whitelistée.
   - [ ] Aucun événement de blocage n'est émis.

## 6. Redémarrage de l'appareil / de l'app

1. Démarrer une session par minuteur de 10 minutes, puis tuer complètement
   le processus de l'app FaithFocus (pas juste la mettre en arrière-plan).
2. Ouvrir l'app tierce non whitelistée.
   - [ ] Le blocage reste actif : `BlockingAccessibilityService` lit l'état
     directement depuis le stockage chiffré (`FocusSessionStore`), pas
     depuis un état en mémoire du process Flutter.

## Limitations connues à garder en tête pendant les tests

- `requestPermissions()` ne peut pas attendre de façon synchrone le retour
  de l'utilisateur depuis les écrans système : il faut le rappeler après
  chaque retour au premier plan de l'app pour connaître l'état à jour.
- La permission `PACKAGE_USAGE_STATS` est déclarée dans le manifeste mais
  n'est utilisée par aucun contrôle actuel (cf. commentaire dans
  `AndroidManifest.xml`) — rien à tester la concernant pour cette tâche.
