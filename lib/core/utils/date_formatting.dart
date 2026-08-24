/// Petits formatteurs de date en français, écrits à la main pour éviter
/// d'ajouter une dépendance (`intl`) juste pour "Jeudi 6 août" / "3 août".
library;

const List<String> _frenchWeekdays = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];

const List<String> _frenchMonths = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// "Jeudi 6 août" — utilisé sur l'Accueil.
String formatFrenchLongDate(DateTime date) {
  final weekday = _frenchWeekdays[date.weekday - 1];
  final month = _frenchMonths[date.month - 1];
  return '$weekday ${date.day} $month';
}

/// "3 août" — utilisé dans les listes de dissertations.
String formatFrenchShortDate(DateTime date) {
  final month = _frenchMonths[date.month - 1];
  return '${date.day} $month';
}
