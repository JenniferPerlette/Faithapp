import 'package:flutter/material.dart';

/// Palette de couleurs unique et restreinte du projet Veille (ex-FaithFocus).
///
/// Contrainte design : aucune autre couleur (hex ad hoc, dégradé) ne doit
/// être introduite ailleurs dans le projet. Toute nouvelle couleur doit être
/// ajoutée ici en premier, jamais écrite en dur dans un widget.
///
/// Les tokens ci-dessous reprennent la palette du design "Veille" (import
/// Claude Design "Veille App.dc.html", tour 1a/2a puis mode sombre 3a/3b) :
/// noms d'accents "Harbor" (bleu), "Mahogany" (terracotta), "Mistelle"
/// (bordeaux) et "Cognac" (corail), déclinés en variante claire et sombre.
abstract final class AppColors {
  // Neutres — clair
  static const Color backgroundLight = Color(0xFFF8F4EF);
  static const Color surfaceLight = Color(0xFFFDFBF9);
  static const Color borderLight = Color(0xFFDFDAD4);
  static const Color textPrimaryLight = Color(0xFF1F1A13);
  static const Color textSecondaryLight = Color(0xFF625D56);

  // Neutres — sombre
  static const Color backgroundDark = Color(0xFF191510);
  static const Color surfaceDark = Color(0xFF28231D);
  static const Color borderDark = Color(0xFF3C3730);
  static const Color textPrimaryDark = Color(0xFFEDEBE7);
  static const Color textSecondaryDark = Color(0xFFA8A49E);

  // Accent "Harbor" (bleu) — CTA principal, état "verrouillé"
  static const Color harborLight = Color(0xFF2F4C5D);
  static const Color harborDark = Color(0xFF7295AA);

  // Accent "Mahogany" (terracotta) — statistiques, accent secondaire
  static const Color mahoganyLight = Color(0xFFA4613D);
  static const Color mahoganyDark = Color(0xFFBC7E5E);

  // Accent "Mistelle" (bordeaux) — badge "Bible toujours autorisée", puces
  static const Color mistelleLight = Color(0xFF4D1C1A);
  static const Color mistelleDark = Color(0xFF904D49);

  // Accent "Cognac" (corail/ambre) — badge "Nouveau", icône Notes
  static const Color cognacLight = Color(0xFFA25E63);
  static const Color cognacDark = Color(0xFFD9B3B4);

  // Écran de blocage ("X est bloquée")
  static const Color blockedBackgroundLight = Color(0xFFEBD9D7);
  static const Color blockedTextLight = Color(0xFF562D2A);
  static const Color blockedBackgroundDark = Color(0xFF130B0A);
  static const Color blockedTextDark = Color(0xFFD9B3B4);

  // Couleurs sémantiques (inchangées entre thèmes, usage ponctuel)
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFB3261E);
}
