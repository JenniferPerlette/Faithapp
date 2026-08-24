import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Regroupe les appels FamilyControls / ManagedSettings / DeviceActivity
/// côté natif iOS. Utilisé à la fois par le process principal (plugin
/// Flutter) et par MonitorExtension (process d'extension séparé) — d'où le
/// passage par un App Group partagé (`AppGroup.identifier`) pour persister
/// la whitelist et l'état de session entre les deux processus.
///
/// Pourquoi cette logique doit être 100% native et jamais côté Dart :
/// Apple n'expose ni la liste des apps installées, ni les noms/identifiants
/// des apps choisies par l'utilisateur — `FamilyActivitySelection` est
/// volontairement opaque (jetons chiffrés), et seul du code natif tournant
/// avec l'entitlement `com.apple.developer.family-controls` peut interagir
/// avec ces API (cf. Tâche 6).
final class ScreenTimeManager {

    static let shared = ScreenTimeManager()

    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()
    private let sharedDefaults = UserDefaults(suiteName: AppGroup.identifier)

    private init() {}

    // MARK: - Autorisation Temps d'écran

    /// Mode `.individual` (auto-restriction), pas `.child` : ce n'est pas un
    /// contrôle parental, l'utilisateur se restreint lui-même.
    func requestAuthorization() async -> Bool {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            return true
        } catch {
            return false
        }
    }

    func isAuthorized() -> Bool {
        AuthorizationCenter.shared.authorizationStatus == .approved
    }

    // MARK: - Sélection de la whitelist (persistée via App Group)

    func loadSelection() -> FamilyActivitySelection {
        guard
            let data = sharedDefaults?.data(forKey: StorageKey.selection),
            let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return FamilyActivitySelection()
        }
        return decoded
    }

    func saveSelection(_ selection: FamilyActivitySelection) {
        guard let data = try? JSONEncoder().encode(selection) else { return }
        sharedDefaults?.set(data, forKey: StorageKey.selection)
    }

    /// Jamais les noms/jetons en clair côté Dart (cf. Tâche 6) : uniquement
    /// un compte, affiché tel quel dans l'UI Flutter ("3 apps autorisées").
    func selectionCount(_ selection: FamilyActivitySelection) -> Int {
        selection.applicationTokens.count
    }

    // MARK: - Session Focus

    var isSessionActive: Bool {
        sharedDefaults?.bool(forKey: StorageKey.sessionActive) ?? false
    }

    /// Bloque toutes les apps SAUF celles de la whitelist. Utilise
    /// délibérément `.all(except:)` plutôt que `store.shield.applications`
    /// (qui exprimerait l'inverse, une liste à bloquer) pour obtenir une
    /// vraie sémantique whitelist cohérente avec le modèle Android.
    ///
    /// ATTENTION : à revérifier dans Xcode contre la version exacte du SDK
    /// ManagedSettings installée — cette API a évolué au fil des versions
    /// d'iOS et n'a pas pu être compilée dans cet environnement (pas de
    /// macOS disponible ici, cf. résumé de Tâche 6).
    func applyShield(selection: FamilyActivitySelection) {
        store.shield.applicationCategories = .all(except: selection.applicationTokens)
        store.shield.applications = nil
        store.shield.webDomainCategories = .all(except: selection.webDomainTokens)
        sharedDefaults?.set(true, forKey: StorageKey.sessionActive)
    }

    func removeShield() {
        store.shield.applicationCategories = nil
        store.shield.applications = nil
        store.shield.webDomainCategories = nil
        sharedDefaults?.set(false, forKey: StorageKey.sessionActive)
    }

    /// Programme un DeviceActivitySchedule : MonitorExtension appliquera et
    /// retirera le shield sur intervalDidStart/intervalDidEnd, y compris si
    /// FaithFocus n'est pas au premier plan ou a été tué (même garantie que
    /// FocusSessionStore côté Android, cf. Tâche 4). Le shield est en plus
    /// appliqué immédiatement ici pour un effet instantané, sans attendre le
    /// prochain passage du système sur l'extension.
    func startSchedule(start: DateComponents, end: DateComponents, selection: FamilyActivitySelection) throws {
        let schedule = DeviceActivitySchedule(
            intervalStart: start,
            intervalEnd: end,
            repeats: false
        )
        try center.startMonitoring(.faithFocusSession, during: schedule)
        applyShield(selection: selection)
    }

    func stopSchedule() {
        center.stopMonitoring([.faithFocusSession])
        removeShield()
    }
}

extension DeviceActivityName {
    static let faithFocusSession = Self("faithFocusSession")
}

enum AppGroup {
    /// Doit correspondre à l'App Group configuré dans les capacités Xcode
    /// du target Runner ET de chaque extension (cf. instructions Xcode en
    /// fin de Tâche 6) : "group.com.faithfocus.faithfocus".
    static let identifier = "group.com.faithfocus.faithfocus"
}

private enum StorageKey {
    static let selection = "faithfocus.family_activity_selection"
    static let sessionActive = "faithfocus.session_active"
}
