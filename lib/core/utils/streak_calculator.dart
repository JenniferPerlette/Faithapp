/// Calcul du streak ("jours de suite"), utilitaire pur Dart testable en
/// isolation. Repris de l'ancien module gamification (streak de leçons de
/// quiz) et adapté au nouveau sens : le streak avance d'un jour à chaque
/// ouverture de l'app sur un jour calendaire différent du dernier.
///
/// AFFICHAGE LOCAL OPTIMISTE : comme documenté avant la suppression du quiz,
/// ce calcul reste local (pas d'horodatage serveur qui ferait foi) — un
/// utilisateur pourrait tricher en changeant l'heure de son téléphone. Pour
/// cette fonctionnalité (motivation personnelle, pas de classement/score
/// public), c'est un compromis acceptable.
library;

class StreakUpdate {
  final int currentStreakDays;
  final int longestStreakDays;

  const StreakUpdate({
    required this.currentStreakDays,
    required this.longestStreakDays,
  });
}

/// Fait avancer le streak pour une activité "aujourd'hui" :
/// - même jour que la dernière activité -> inchangé (déjà comptabilisé)
/// - jour suivant -> +1
/// - plus d'un jour d'écart (ou jamais d'activité) -> repart à 1
StreakUpdate advanceStreakForToday({
  required DateTime? lastActivityDate,
  required int currentStreakDays,
  required int longestStreakDays,
  DateTime? now,
}) {
  final today = _dateOnly(now ?? DateTime.now());

  if (lastActivityDate == null) {
    return const StreakUpdate(currentStreakDays: 1, longestStreakDays: 1);
  }

  final gapDays = today.difference(_dateOnly(lastActivityDate)).inDays;
  final int newCurrentStreak;
  if (gapDays <= 0) {
    newCurrentStreak = currentStreakDays;
  } else if (gapDays == 1) {
    newCurrentStreak = currentStreakDays + 1;
  } else {
    newCurrentStreak = 1;
  }

  return StreakUpdate(
    currentStreakDays: newCurrentStreak,
    longestStreakDays: newCurrentStreak > longestStreakDays
        ? newCurrentStreak
        : longestStreakDays,
  );
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
