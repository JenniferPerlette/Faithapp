import ManagedSettings
import Foundation

/// Gère les taps sur les boutons du Shield (cf. Tâche 6). Comportement
/// imposé par les limites Apple :
/// - Bouton primaire "Faire un quiz" : pas de navigation en place possible
///   pendant l'affichage du Shield — on ouvre FaithFocus via l'URL scheme
///   faithfocus://quiz/random (`extensionContext?.open`, seul mécanisme
///   disponible pour qu'une extension déclenche l'ouverture d'une app).
/// - Bouton secondaire "Retour à l'accueil" : ferme simplement le Shield
///   (`ShieldActionResponse.close`), qui révèle l'écran précédant
///   l'ouverture de l'app bloquée (pas l'app bloquée elle-même).
class ShieldActionExtension: ShieldActionDelegate {

    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        respond(to: action, completionHandler: completionHandler)
    }

    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        respond(to: action, completionHandler: completionHandler)
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        respond(to: action, completionHandler: completionHandler)
    }

    private func respond(
        to action: ShieldAction,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            if let url = URL(string: "faithfocus://quiz/random") {
                extensionContext?.open(url, completionHandler: nil)
            }
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
}
