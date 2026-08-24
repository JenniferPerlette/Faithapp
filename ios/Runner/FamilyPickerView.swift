import SwiftUI
import FamilyControls

/// Écran de sélection de la whitelist. Le choix des apps passe
/// obligatoirement par le `FamilyActivityPicker` système d'Apple — il est
/// impossible de lister les apps installées ou de construire une UI Flutter
/// équivalente (cf. Tâche 6). Le résumé affiché sous le bouton utilise
/// l'initialiseur officiel `Label(_ application:)`, qui restitue icône et
/// nom sans jamais exposer ces informations à notre code : la sélection
/// reste opaque de bout en bout.
///
/// Limite Apple à connaître : il n'existe pas de moyen de pré-cocher une
/// entrée de façon non décochable dans ce picker système. La sélection
/// précédente est pré-remplie par défaut, et un texte d'avertissement
/// rappelle de garder FaithFocus + l'app biblique cochées — la seule
/// protection réellement garantie par le code reste le refus de démarrer
/// une session avec une sélection vide (cf. AppBlockerPlugin).
struct FamilyPickerView: View {
    @State private var selection: FamilyActivitySelection
    @State private var isPickerPresented = false
    let onDone: (FamilyActivitySelection) -> Void

    init(
        initialSelection: FamilyActivitySelection,
        onDone: @escaping (FamilyActivitySelection) -> Void
    ) {
        _selection = State(initialValue: initialSelection)
        self.onDone = onDone
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Apps autorisées pendant le Jeûne Digital")
                .font(.headline)
                .foregroundColor(FaithFocusColors.textPrimary)

            Text("Gardez FaithFocus et votre app biblique cochées pour ne pas vous bloquer vous-même.")
                .font(.footnote)
                .foregroundColor(FaithFocusColors.textSecondary)

            if selection.applicationTokens.isEmpty {
                Text("Aucune app sélectionnée")
                    .foregroundColor(FaithFocusColors.textSecondary)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(selection.applicationTokens), id: \.self) { token in
                            Label(token)
                        }
                    }
                }
            }

            Button("Choisir les apps") {
                isPickerPresented = true
            }
            .foregroundColor(FaithFocusColors.primary)

            Spacer()

            Button("Valider") {
                onDone(selection)
            }
            .disabled(selection.applicationTokens.isEmpty)
            .foregroundColor(FaithFocusColors.surface)
            .padding()
            .frame(maxWidth: .infinity)
            .background(selection.applicationTokens.isEmpty ? FaithFocusColors.textSecondary : FaithFocusColors.primary)
        }
        .padding()
        .background(FaithFocusColors.background)
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
    }
}
