/// Logique pure (donc facilement testable) de la période verrouillée
/// quotidienne : verrouillé de minuit jusqu'à l'heure de déblocage choisie
/// par l'utilisateur, libre le reste de la journée, et ça recommence le
/// lendemain.
library;

bool isLockedAt(DateTime now, int unlockTimeMinutes) {
  final minutesSinceMidnight = now.hour * 60 + now.minute;
  return minutesSinceMidnight < unlockTimeMinutes;
}

/// Ne doit être appelé que quand [isLockedAt] est vrai : l'heure de
/// déblocage n'est pas encore passée aujourd'hui.
DateTime unlockTimeToday(DateTime now, int unlockTimeMinutes) {
  return DateTime(
    now.year,
    now.month,
    now.day,
    unlockTimeMinutes ~/ 60,
    unlockTimeMinutes % 60,
  );
}

Duration remainingUntilUnlock(DateTime now, int unlockTimeMinutes) {
  final unlock = unlockTimeToday(now, unlockTimeMinutes);
  final remaining = unlock.difference(now);
  return remaining.isNegative ? Duration.zero : remaining;
}

/// Formate une durée en "3 h 12" (heures + minutes) ou "12 min" si moins
/// d'une heure — reprend le format vu dans le design
/// ("Encore 3 h 12 avant le déblocage").
String formatDurationHm(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return '$hours h ${minutes.toString().padLeft(2, '0')}';
  }
  return '$minutes min';
}
