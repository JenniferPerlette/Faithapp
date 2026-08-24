import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    AppBlockerPlugin.register(with: engineBridge.pluginRegistry.registrar(forPlugin: "AppBlockerPlugin")!)
  }

  /// Reçoit faithfocus://quiz/random, ouvert par ShieldActionExtension
  /// quand l'utilisateur tape "Faire un quiz" sur le Shield (cf. Tâche 6).
  /// TODO(Tâche 8) : la navigation Flutter vers un quiz aléatoire non
  /// complété n'existe pas encore — pour l'instant, ceci ramène seulement
  /// FaithFocus au premier plan.
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    guard url.scheme == "faithfocus" else {
      return super.application(app, open: url, options: options)
    }
    return true
  }
}
