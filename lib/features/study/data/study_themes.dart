import 'package:flutter/foundation.dart';

/// Un verset suggéré pendant la recherche (écran "Recherche en cours").
@immutable
class SuggestedVerse {
  final String text;
  final String reference;

  const SuggestedVerse(this.text, this.reference);
}

/// Un thème d'étude proposé sur l'écran "Choisis un thème". Contenu
/// applicatif statique (comme l'étaient les questions du quiz avant) : pas
/// besoin de Firestore pour ça.
@immutable
class StudyTheme {
  final String id;
  final String title;
  final String verseRefs;
  final List<SuggestedVerse> suggestedVerses;

  const StudyTheme({
    required this.id,
    required this.title,
    required this.verseRefs,
    required this.suggestedVerses,
  });
}

/// Durée de la période de recherche avant la rédaction obligatoire, comme
/// dans le design ("Commencer ma recherche · 45 min").
const Duration kStudyResearchDuration = Duration(minutes: 45);

const List<StudyTheme> studyThemes = [
  StudyTheme(
    id: 'patience',
    title: 'La patience',
    verseRefs: 'Jacques 1:2-4 · Romains 5:3-5',
    suggestedVerses: [
      SuggestedVerse(
        "La patience mène l'épreuve à son plein effet.",
        'Jacques 1:4',
      ),
      SuggestedVerse(
        'La persévérance produit une vertu éprouvée.',
        'Romains 5:4',
      ),
    ],
  ),
  StudyTheme(
    id: 'pardon',
    title: 'Le pardon',
    verseRefs: 'Matthieu 18:21-22 · Colossiens 3:13',
    suggestedVerses: [
      SuggestedVerse(
        'Pardonne, non pas sept fois, mais soixante-dix fois sept fois.',
        'Matthieu 18:22',
      ),
      SuggestedVerse(
        'Pardonnez-vous réciproquement, comme le Seigneur vous a pardonné.',
        'Colossiens 3:13',
      ),
    ],
  ),
  StudyTheme(
    id: 'esperance',
    title: "L'espérance",
    verseRefs: 'Romains 15:13 · Hébreux 11:1',
    suggestedVerses: [
      SuggestedVerse(
        "Que le Dieu de l'espérance vous remplisse de joie et de paix.",
        'Romains 15:13',
      ),
      SuggestedVerse(
        'La foi est une ferme assurance des choses qu\'on espère.',
        'Hébreux 11:1',
      ),
    ],
  ),
  StudyTheme(
    id: 'amour',
    title: "L'amour du prochain",
    verseRefs: '1 Corinthiens 13 · Marc 12:31',
    suggestedVerses: [
      SuggestedVerse(
        "L'amour prend patience, il rend service, il ne s'irrite pas.",
        '1 Corinthiens 13:4',
      ),
      SuggestedVerse(
        'Tu aimeras ton prochain comme toi-même.',
        'Marc 12:31',
      ),
    ],
  ),
  StudyTheme(
    id: 'justice',
    title: 'La justice',
    verseRefs: 'Michée 6:8 · Ésaïe 1:17',
    suggestedVerses: [
      SuggestedVerse(
        'Ce que demande l\'Éternel : pratiquer la justice.',
        'Michée 6:8',
      ),
      SuggestedVerse(
        "Défendez l'opprimé, faites droit à l'orphelin.",
        'Ésaïe 1:17',
      ),
    ],
  ),
  StudyTheme(
    id: 'foi',
    title: 'La foi',
    verseRefs: 'Hébreux 11:1 · Romains 10:17',
    suggestedVerses: [
      SuggestedVerse(
        'La foi vient de ce qu\'on entend.',
        'Romains 10:17',
      ),
      SuggestedVerse(
        "Une ferme assurance des choses qu'on espère.",
        'Hébreux 11:1',
      ),
    ],
  ),
];

StudyTheme? studyThemeById(String id) {
  for (final theme in studyThemes) {
    if (theme.id == id) return theme;
  }
  return null;
}
