import DeviceActivity
import ManagedSettings

/// S'exécute dans son propre process, indépendamment de l'app principale
/// FaithFocus (même garantie que BlockingAccessibilityService côté
/// Android, cf. Tâche 4) : applique/retire le Shield au début/à la fin de
/// la fenêtre planifiée par ScreenTimeManager.startSchedule, y compris si
/// l'app FaithFocus n'est pas au premier plan ou a été tuée.
///
/// NOTE D'INTÉGRATION XCODE : ScreenTimeManager.swift et
/// FaithFocusColors.swift doivent être ajoutés à la Target Membership de
/// CETTE extension en plus du target Runner (cf. instructions Xcode en fin
/// de Tâche 6).
class MonitorExtension: DeviceActivityMonitor {

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard activity == .faithFocusSession else { return }
        let selection = ScreenTimeManager.shared.loadSelection()
        ScreenTimeManager.shared.applyShield(selection: selection)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        guard activity == .faithFocusSession else { return }
        ScreenTimeManager.shared.removeShield()
    }
}
