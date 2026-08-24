import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Configuration du Shield affiché par le système quand une app non
/// whitelistée est ouverte pendant une session Focus. Limites Apple à
/// respecter strictement (cf. Tâche 6) :
/// - Titre/sous-titre fixés une seule fois à la construction du Shield —
///   le nom de l'app provient de `application.localizedDisplayName`
///   (exposé par Apple spécifiquement à cette extension), mais aucun
///   compteur ou contenu n'est mis à jour en direct après affichage.
/// - Une seule icône/couleur pour tout le Shield (pas d'icône par app).
/// - Deux boutons maximum, dont l'action est gérée par
///   ShieldActionExtension (pas de navigation en place possible ici).
/// Couleurs exclusivement issues de FaithFocusColors (palette du projet) —
/// aucun dégradé.
///
/// NOTE D'INTÉGRATION XCODE : FaithFocusColors.swift doit être ajouté à la
/// Target Membership de CETTE extension (cf. instructions Xcode en fin de
/// Tâche 6).
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        Self.configuration(appName: application.localizedDisplayName)
    }

    override func configuration(
        shielding application: Application,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        Self.configuration(appName: application.localizedDisplayName)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        Self.configuration(appName: webDomain.domain)
    }

    override func configuration(
        shielding webDomain: WebDomain,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        Self.configuration(appName: webDomain.domain)
    }

    private static func configuration(appName: String?) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: nil,
            backgroundColor: UIColor(FaithFocusColors.background),
            icon: UIImage(systemName: "book.closed.fill"),
            title: ShieldConfiguration.Label(
                text: "\(appName ?? "Cette application") est en pause",
                color: UIColor(FaithFocusColors.textPrimary)
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Reviens à l'essentiel pendant ta session Focus.",
                color: UIColor(FaithFocusColors.textSecondary)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Faire un quiz de 3 minutes",
                color: UIColor(FaithFocusColors.surface)
            ),
            primaryButtonBackgroundColor: UIColor(FaithFocusColors.primary),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Retour à l'accueil",
                color: UIColor(FaithFocusColors.textSecondary)
            )
        )
    }
}
