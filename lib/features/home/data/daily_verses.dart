import 'package:flutter/foundation.dart';

/// Un verset affiché sur la carte "Verset du jour" de l'Accueil verrouillé.
@immutable
class DailyVerse {
  final String text;
  final String reference;

  const DailyVerse(this.text, this.reference);
}

/// Bibliothèque de versets locale (contenu applicatif statique, comme
/// l'étaient les questions du quiz avant) — le "Verset du jour" tourne de
/// façon déterministe selon le jour de l'année, sans dépendre du réseau.
const List<DailyVerse> dailyVerses = [
  DailyVerse('Que la lumière soit ta compagne dans l\'attente.', 'Psaumes 27:1'),
  DailyVerse('Sois fort et prends courage.', 'Josué 1:9'),
  DailyVerse(
    'Confie-toi en l\'Éternel de tout ton cœur.',
    'Proverbes 3:5',
  ),
  DailyVerse(
    'Je puis tout par celui qui me fortifie.',
    'Philippiens 4:13',
  ),
  DailyVerse(
    'L\'Éternel est mon berger : je ne manquerai de rien.',
    'Psaumes 23:1',
  ),
  DailyVerse(
    'Ta parole est une lampe à mes pieds.',
    'Psaumes 119:105',
  ),
  DailyVerse(
    'Ne t\'inquiète de rien, mais en toute chose... fais tes demandes.',
    'Philippiens 4:6',
  ),
];

/// Choisit un verset de façon déterministe pour une date donnée (même
/// verset toute la journée, change le lendemain).
DailyVerse dailyVerseFor(DateTime date) {
  final dayOfYear = int.parse(
    '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
  );
  return dailyVerses[dayOfYear % dailyVerses.length];
}
