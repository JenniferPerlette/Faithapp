import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Une application candidate à la liste des "alliées" — les applications
/// (en plus de la Bible, toujours autorisée) que l'utilisateur peut choisir
/// de garder accessibles pendant la période verrouillée. Repris de l'écran
/// "Modifier tes applications" du design.
@immutable
class AllowedAppOption {
  final String id;
  final String label;
  final IconData icon;

  /// Couleur claire/sombre de la puce dans la liste des applications
  /// autorisées (écran Accueil verrouillé) — `null` pour les apps jamais
  /// mises en avant dans le design (Photos/Musique/Calendrier), qui restent
  /// simplement des cases à cocher neutres.
  final Color? accentLight;
  final Color? accentDark;

  const AllowedAppOption({
    required this.id,
    required this.label,
    required this.icon,
    this.accentLight,
    this.accentDark,
  });

  Color? accentFor(Brightness brightness) =>
      brightness == Brightness.dark ? accentDark : accentLight;
}

/// Identifiant réservé de la Bible : toujours incluse, jamais désactivable,
/// jamais comptée dans la limite de [UserProfile.kMaxAllowedApps].
const String kBibleAppId = 'bible';

/// Catalogue des applications proposées à l'onboarding et sur l'écran
/// "Modifier tes applications" du Profil.
abstract final class AllowedAppsCatalog {
  static const bible = AllowedAppOption(
    id: kBibleAppId,
    label: 'Bible',
    icon: Icons.menu_book_outlined,
    accentLight: AppColors.harborLight,
    accentDark: AppColors.harborDark,
  );

  static const List<AllowedAppOption> selectable = [
    AllowedAppOption(
      id: 'phone',
      label: 'Téléphone',
      icon: Icons.call_outlined,
      accentLight: AppColors.mahoganyLight,
      accentDark: AppColors.mahoganyDark,
    ),
    AllowedAppOption(
      id: 'notes',
      label: 'Notes',
      icon: Icons.sticky_note_2_outlined,
      accentLight: AppColors.cognacLight,
      accentDark: AppColors.cognacDark,
    ),
    AllowedAppOption(id: 'photos', label: 'Photos', icon: Icons.image_outlined),
    AllowedAppOption(
      id: 'music',
      label: 'Musique',
      icon: Icons.music_note_outlined,
    ),
    AllowedAppOption(
      id: 'calendar',
      label: 'Calendrier',
      icon: Icons.calendar_today_outlined,
    ),
  ];

  static AllowedAppOption? byId(String id) {
    for (final app in selectable) {
      if (app.id == id) return app;
    }
    return null;
  }
}
