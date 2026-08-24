import SwiftUI

/// Synchronisé manuellement avec lib/core/theme/app_colors.dart et
/// android/app/src/main/res/values/colors.xml (palette plate unique du
/// projet — cf. contraintes de design transverses). Toute modification de
/// la palette Dart doit être reportée ici.
enum FaithFocusColors {
    static let primary = Color(red: 0x2F / 255, green: 0x52 / 255, blue: 0x33 / 255)
    static let accent = Color(red: 0xC9 / 255, green: 0xA2 / 255, blue: 0x4B / 255)
    static let background = Color(red: 0xFA / 255, green: 0xF9 / 255, blue: 0xF6 / 255)
    static let surface = Color(red: 0xFF / 255, green: 0xFF / 255, blue: 0xFF / 255)
    static let textSecondary = Color(red: 0x6B / 255, green: 0x72 / 255, blue: 0x80 / 255)
    static let textPrimary = Color(red: 0x1F / 255, green: 0x29 / 255, blue: 0x37 / 255)
    static let success = Color(red: 0x2E / 255, green: 0x7D / 255, blue: 0x32 / 255)
    static let error = Color(red: 0xB3 / 255, green: 0x26 / 255, blue: 0x1E / 255)
}
