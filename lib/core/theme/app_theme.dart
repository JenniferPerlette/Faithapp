import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Jetons de couleur "Veille" qui n'ont pas d'équivalent direct dans
/// [ColorScheme] (Harbor/Mahogany/Mistelle/Cognac + écran de blocage).
/// Accessible via `Theme.of(context).extension<VeilleColors>()!`.
class VeilleColors extends ThemeExtension<VeilleColors> {
  final Color harbor;
  final Color mahogany;
  final Color mistelle;
  final Color cognac;
  final Color blockedBackground;
  final Color blockedText;

  const VeilleColors({
    required this.harbor,
    required this.mahogany,
    required this.mistelle,
    required this.cognac,
    required this.blockedBackground,
    required this.blockedText,
  });

  static const light = VeilleColors(
    harbor: AppColors.harborLight,
    mahogany: AppColors.mahoganyLight,
    mistelle: AppColors.mistelleLight,
    cognac: AppColors.cognacLight,
    blockedBackground: AppColors.blockedBackgroundLight,
    blockedText: AppColors.blockedTextLight,
  );

  static const dark = VeilleColors(
    harbor: AppColors.harborDark,
    mahogany: AppColors.mahoganyDark,
    mistelle: AppColors.mistelleDark,
    cognac: AppColors.cognacDark,
    blockedBackground: AppColors.blockedBackgroundDark,
    blockedText: AppColors.blockedTextDark,
  );

  @override
  VeilleColors copyWith({
    Color? harbor,
    Color? mahogany,
    Color? mistelle,
    Color? cognac,
    Color? blockedBackground,
    Color? blockedText,
  }) {
    return VeilleColors(
      harbor: harbor ?? this.harbor,
      mahogany: mahogany ?? this.mahogany,
      mistelle: mistelle ?? this.mistelle,
      cognac: cognac ?? this.cognac,
      blockedBackground: blockedBackground ?? this.blockedBackground,
      blockedText: blockedText ?? this.blockedText,
    );
  }

  @override
  VeilleColors lerp(ThemeExtension<VeilleColors>? other, double t) {
    if (other is! VeilleColors) return this;
    return VeilleColors(
      harbor: Color.lerp(harbor, other.harbor, t)!,
      mahogany: Color.lerp(mahogany, other.mahogany, t)!,
      mistelle: Color.lerp(mistelle, other.mistelle, t)!,
      cognac: Color.lerp(cognac, other.cognac, t)!,
      blockedBackground: Color.lerp(
        blockedBackground,
        other.blockedBackground,
        t,
      )!,
      blockedText: Color.lerp(blockedText, other.blockedText, t)!,
    );
  }
}

/// Accès pratique à [VeilleColors] depuis un [BuildContext].
extension VeilleColorsExtension on BuildContext {
  VeilleColors get veilleColors => Theme.of(this).extension<VeilleColors>()!;
}

/// Thèmes Material 3 clair et sombre de l'application, construits
/// exclusivement à partir de [AppColors]. Aucune couleur ne doit être
/// définie ailleurs.
///
/// Typographie du design "Veille" : Newsreader (serif, citations/titres
/// contemplatifs, souvent en italique) + Inter (sans-serif, corps de texte
/// et UI), chargées via `google_fonts` (pas d'assets à embarquer).
abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    border: AppColors.borderLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    primary: AppColors.harborLight,
    veilleColors: VeilleColors.light,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    border: AppColors.borderDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    primary: AppColors.harborDark,
    veilleColors: VeilleColors.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color primary,
    required VeilleColors veilleColors,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      surface: surface,
      error: AppColors.error,
    );

    final baseTextTheme = brightness == Brightness.light
        ? Typography.material2021().black
        : Typography.material2021().white;

    final interTextTheme = GoogleFonts.interTextTheme(baseTextTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      // Élévations discrètes uniquement (tonal elevation Material 3),
      // pas d'ombre portée prononcée ni de dégradé.
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      dividerColor: border,
      textTheme: interTextTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: surface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: const StadiumBorder(),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: background,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
      ),
      extensions: [veilleColors],
    );
  }

  /// Style "Newsreader" italique utilisé pour les titres contemplatifs et
  /// les citations bibliques dans tout le design Veille.
  static TextStyle newsreader(
    BuildContext context, {
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w500,
    FontStyle fontStyle = FontStyle.italic,
    Color? color,
  }) {
    return GoogleFonts.newsreader(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}
