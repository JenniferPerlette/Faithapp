# Checklist de test manuel — Tâche 5 (overlay de verrouillage Android)

Comme pour la Tâche 4, ce composant (fenêtre système par-dessus une autre
app, Compose hébergé dans un Service) ne se valide pas de façon fiable en
test unitaire : à exécuter sur un **appareil physique** ou un émulateur
avec les permissions overlay + accessibilité déjà accordées (cf. checklist
Tâche 4). Prérequis : une session Focus active, une app tierce non
whitelistée installée.

## 1. Apparence et contenu à l'ouverture

1. Ouvrir l'app tierce non whitelistée pendant la session.
   - [ ] L'overlay recouvre tout l'écran, en couleurs plates issues de
     `colors.xml` (fond `ff_background`) — aucun dégradé.
   - [ ] Le titre affiche "{Nom lisible de l'app} est en pause" (le vrai
     nom affiché à l'utilisateur, pas le nom de package brut).
   - [ ] Un message motivant est affiché, non culpabilisant.
   - [ ] Le temps restant de la session est affiché.

## 2. Rotation des messages

1. Fermer puis rouvrir l'app tierce plusieurs fois de suite (ou changer
   d'app non whitelistée) pour redéclencher l'overlay plusieurs fois.
   - [ ] Le message affiché n'est jamais identique deux fois d'affilée.
   - [ ] Sur une dizaine d'essais, des messages des 4 tons (recentrage
     doux, invitation, neutre/factuel, curiosité) apparaissent.

## 3. Mise à jour du temps restant

1. Laisser l'overlay affiché au moins 2 minutes sans interaction.
   - [ ] Le temps restant se met à jour au moins une fois par minute.

## 4. Non-fermeture automatique

1. Démarrer une session longue (ex. 15 minutes), déclencher l'overlay, puis
   ne rien faire pendant plusieurs minutes.
   - [ ] L'overlay reste affiché indéfiniment : aucune fermeture
     automatique liée à l'inactivité.

## 5. Bouton "Faire un quiz de 3 minutes"

1. Appuyer sur ce bouton.
   - [ ] L'overlay se ferme.
   - [ ] FaithFocus revient au premier plan.
   - [ ] TODO attendu (Tâche 8 non encore implémentée) : l'app ne navigue
     pas encore vers un quiz aléatoire précis, seul le retour au premier
     plan de l'app est actuellement câblé côté natif.

## 6. Bouton "Retour à l'accueil"

1. Rouvrir l'app tierce pour redéclencher l'overlay, puis appuyer sur ce
   bouton.
   - [ ] L'overlay se ferme.
   - [ ] L'écran d'accueil du téléphone s'affiche (pas l'app tierce
     bloquée en arrière-plan).

## 7. Fin de session pendant que l'overlay est affiché

1. Déclencher l'overlay avec un minuteur/plage horaire sur le point
   d'expirer, et laisser l'overlay affiché jusqu'à l'expiration.
   - [ ] L'overlay se ferme automatiquement à la fin de la session (ce
     n'est pas une fermeture par inactivité : la session elle-même est
     terminée, cf. Tâche 4).

## Limitations connues à garder en tête pendant les tests

- Le bouton quiz ne route pas encore vers un quiz aléatoire précis : la
  navigation Flutter correspondante n'existe qu'à partir de la Tâche 8.
- Le démarrage du service depuis `BlockingAccessibilityService` (donc
  potentiellement pendant que FaithFocus est en arrière-plan) n'a pas été
  vérifié sur toutes les versions/constructeurs Android vis-à-vis des
  restrictions de démarrage de service en arrière-plan (Android 8+) : à
  surveiller en priorité si l'overlay ne s'affiche pas sur un appareil
  donné — un passage à `startForegroundService` + notification pourrait
  être nécessaire selon les résultats.
- Le rendu exact autour de la barre de statut/encoches n'a pas été affiné
  visuellement (flags `WindowManager` volontairement simples) : à ajuster
  si besoin après retour visuel sur device réel.
