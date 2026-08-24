# Configuration Xcode requise — Tâche 6 (iOS FamilyControls)

Tous les fichiers Swift/Info.plist/entitlements de la Tâche 6 ont été écrits
dans `ios/`, mais **aucune compilation n'a pu être vérifiée** dans cet
environnement (pas de macOS/Xcode disponible ici). Ce document liste les
étapes à faire sur un Mac avant que le projet compile.

## 0. Prérequis côté compte développeur Apple

- **`com.apple.developer.family-controls` est un entitlement restreint** :
  il faut en faire la demande auprès d'Apple (formulaire dédié dans le
  Developer Portal, délai de traitement variable) avant de pouvoir signer
  et exécuter l'app sur un device réel avec cet entitlement actif. Sans
  cette approbation, le build fonctionne en simulateur pour le
  développement UI, mais `AuthorizationCenter.shared.requestAuthorization`
  échouera sur device.
- Activer l'**App Group** `group.com.faithfocus.faithfocus` dans
  Certificates, Identifiers & Profiles pour l'App ID de Runner ET pour
  chaque extension.

## 1. Créer les 3 targets d'extension

Dans Xcode : `File > New > Target...`, puis pour chacune :

| Target à créer | Type de template Xcode | Fichiers à glisser dedans (Target Membership) |
|---|---|---|
| `DeviceActivityMonitorExtension` | "Device Activity Monitor Extension" | `MonitorExtension.swift`, **+ `ScreenTimeManager.swift` et `FaithFocusColors.swift` en Target Membership additionnelle** |
| `ShieldConfigurationExtension` | "Shield Configuration Extension" | `ShieldConfigurationExtension.swift`, **+ `FaithFocusColors.swift` en Target Membership additionnelle** |
| `ShieldActionExtension` | "Shield Action Extension" | `ShieldActionExtension.swift` |

Après création de chaque target, Xcode génère ses propres
`Info.plist`/fichier Swift stub — **remplacer** ces fichiers générés par
ceux fournis dans `ios/<NomExtension>/`, ou fusionner le contenu du
`NSExtension` dict si Xcode a déjà correctement pré-rempli
`NSExtensionPointIdentifier`.

Pour chaque target, dans l'onglet **Signing & Capabilities** :
- Ajouter la capability **App Groups**, cocher `group.com.faithfocus.faithfocus`.
- Ajouter la capability **Family Controls** (disponible une fois
  l'entitlement approuvé par Apple sur le compte développeur).
- Remplacer le fichier `.entitlements` généré par celui fourni dans
  `ios/<NomExtension>/<NomExtension>.entitlements`, ou reporter son contenu.

## 2. Target Runner

- Onglet **Signing & Capabilities** : ajouter **App Groups**
  (`group.com.faithfocus.faithfocus`) et **Family Controls**.
- Vérifier que `ios/Runner/Runner.entitlements` est bien référencé dans
  Build Settings → `CODE_SIGN_ENTITLEMENTS`.
- S'assurer que `AppBlockerPlugin.swift`, `ScreenTimeManager.swift`,
  `FamilyPickerView.swift`, `FaithFocusColors.swift` sont dans la Target
  Membership de Runner (normalement automatique si ajoutés via Xcode dans
  le groupe `Runner`).

## 2bis. Fichier de confidentialité (Privacy Manifest)

`ios/Runner/PrivacyInfo.xcprivacy` a été ajouté (Tâche 10) pour déclarer
l'usage de `UserDefaults(suiteName:)` par `ScreenTimeManager.swift`, une
"required reason API" pour Apple depuis 2024. Comme pour les extensions,
Xcode doit être ouvert pour l'ajouter à la Target Membership de **Runner**
(clic droit sur le fichier dans le Project Navigator si absent des
membership de la target après ouverture du projet).

## 3. Vérifications après premier build

- `flutter build ios` (ou build via Xcode) doit réussir sans erreur de
  résolution de symboles (`ManagedSettingsStore`, `DeviceActivityCenter`,
  `FamilyActivityPicker`, etc.) — sinon, vérifier la version minimale iOS
  déployée (`FamilyControls` nécessite iOS 15+, certaines API comme
  `.all(except:)` nécessitent iOS 16+ : à confirmer contre la documentation
  Apple à jour dans Xcode, cf. commentaire dans `ScreenTimeManager.swift`).
- Vérifier `Deployment Target` ≥ 16.0 sur Runner et les 3 extensions.

## Points de vigilance signalés dans le code

- `ScreenTimeManager.applyShield` utilise `.all(except:)` — API à
  reconfirmer contre le SDK exact installé (non compilable ici).
- `AppBlockerPlugin.handleStartFocusSession` convertit les dates en
  `DateComponents` (heure du jour) pour `DeviceActivitySchedule`, qui ne
  représente pas nativement une plage absolue — limite documentée en ligne
  pour les sessions chevauchant minuit.
