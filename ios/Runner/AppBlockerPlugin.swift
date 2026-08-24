import Flutter
import UIKit
import SwiftUI
import FamilyControls

/// Pont MethodChannel/EventChannel "com.faithfocus/blocker" côté iOS.
///
/// Asymétries assumées avec Android (cf. résumé de Tâche 6) :
/// - `startFocusSession` ignore `whitelistedPackageIds` : sur iOS, la
///   whitelist provient exclusivement du `FamilyActivityPicker` natif via
///   `presentFamilyActivityPicker`, une méthode additionnelle hors de
///   l'interface Dart commune définie en Tâche 3 (nécessaire : Apple
///   n'expose pas la liste des apps installées, impossible de réutiliser
///   l'UI Flutter de whitelist d'Android).
/// - `onBlockedAppAttempt` n'émet jamais rien sur iOS : le Shield est
///   affiché par un process d'extension Apple indépendant
///   (ShieldConfigurationExtension), qui ne notifie pas le process
///   principal Flutter des tentatives bloquées en temps réel.
final class AppBlockerPlugin: NSObject, FlutterPlugin {

    private static let methodChannelName = "com.faithfocus/blocker"
    private static let eventChannelName = "com.faithfocus/blocker_events"
    private static let maxTimerSeconds = 24 * 60 * 60

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AppBlockerPlugin()

        let methodChannel = FlutterMethodChannel(
            name: methodChannelName,
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        let eventChannel = FlutterEventChannel(
            name: eventChannelName,
            binaryMessenger: registrar.messenger()
        )
        eventChannel.setStreamHandler(instance)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestPermissions":
            Task {
                let granted = await ScreenTimeManager.shared.requestAuthorization()
                result(granted)
            }
        case "presentFamilyActivityPicker":
            presentPicker(result: result)
        case "getWhitelistSelectionCount":
            let selection = ScreenTimeManager.shared.loadSelection()
            result(ScreenTimeManager.shared.selectionCount(selection))
        case "startFocusSession":
            handleStartFocusSession(call, result: result)
        case "stopFocusSession":
            ScreenTimeManager.shared.stopSchedule()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Refuse explicitement de rouvrir le picker pendant une session active
    /// (règle validée en Tâche 6 : la whitelist ne se modifie pas pendant
    /// le blocage).
    private func presentPicker(result: @escaping FlutterResult) {
        guard !ScreenTimeManager.shared.isSessionActive else {
            result(FlutterError(
                code: "session_active",
                message: "La whitelist ne peut pas être modifiée pendant une session Focus active.",
                details: nil
            ))
            return
        }

        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController
        else {
            result(FlutterError(code: "no_root_view_controller", message: nil, details: nil))
            return
        }

        let initialSelection = ScreenTimeManager.shared.loadSelection()
        let pickerView = FamilyPickerView(initialSelection: initialSelection) { selection in
            ScreenTimeManager.shared.saveSelection(selection)
            rootViewController.dismiss(animated: true) {
                result(ScreenTimeManager.shared.selectionCount(selection))
            }
        }
        let hostingController = UIHostingController(rootView: pickerView)
        hostingController.modalPresentationStyle = .formSheet
        rootViewController.present(hostingController, animated: true)
    }

    private func handleStartFocusSession(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let selection = ScreenTimeManager.shared.loadSelection()
        guard ScreenTimeManager.shared.selectionCount(selection) > 0 else {
            result(FlutterError(
                code: "empty_whitelist",
                message: "Choisissez au moins une app autorisée avant de démarrer une session Focus.",
                details: nil
            ))
            return
        }

        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "invalid_arguments", message: nil, details: nil))
            return
        }

        let now = Date()
        let startDate: Date
        let endDate: Date

        if let timerSeconds = args["timerDurationSeconds"] as? Int {
            guard timerSeconds > 0, timerSeconds <= Self.maxTimerSeconds else {
                result(FlutterError(code: "invalid_arguments", message: "timerDurationSeconds invalide", details: nil))
                return
            }
            startDate = now
            endDate = now.addingTimeInterval(TimeInterval(timerSeconds))
        } else if
            let scheduledStartString = args["scheduledStart"] as? String,
            let scheduledEndString = args["scheduledEnd"] as? String,
            let parsedStart = ISO8601DateFormatter.faithFocus.date(from: scheduledStartString),
            let parsedEnd = ISO8601DateFormatter.faithFocus.date(from: scheduledEndString)
        {
            startDate = parsedStart
            endDate = parsedEnd
        } else {
            result(FlutterError(
                code: "invalid_arguments",
                message: "Ni minuteur ni plage horaire valide fournis",
                details: nil
            ))
            return
        }

        guard endDate > startDate else {
            result(FlutterError(
                code: "invalid_arguments",
                message: "La fin de session doit être après le début",
                details: nil
            ))
            return
        }

        do {
            // LIMITE CONNUE : DeviceActivitySchedule raisonne en heure du
            // jour (DateComponents hour/minute/second), pas en date/heure
            // absolue. Une session qui chevauche minuit n'est donc pas
            // fiablement représentée par cette conversion — acceptable pour
            // des sessions courtes (le cas d'usage principal), à retravailler
            // si des sessions multi-jours sont nécessaires. Non vérifié par
            // compilation réelle (pas de macOS dans cet environnement).
            try ScreenTimeManager.shared.startSchedule(
                start: Calendar.current.dateComponents([.hour, .minute, .second], from: startDate),
                end: Calendar.current.dateComponents([.hour, .minute, .second], from: endDate),
                selection: selection
            )
            result(nil)
        } catch {
            result(FlutterError(code: "schedule_failed", message: error.localizedDescription, details: nil))
        }
    }
}

extension AppBlockerPlugin: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        nil
    }
}

private extension ISO8601DateFormatter {
    static let faithFocus: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
