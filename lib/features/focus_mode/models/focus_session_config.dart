/// Modèles d'état du mode Focus (Tâche 7).
///
/// Ces classes ne représentent que l'état local de session (UI + pilotage
/// du natif via [AppBlockerChannel]) : elles n'ont pas vocation à être
/// synchronisées avec Firestore.
library;

/// Identifiant de package/bundle de Veille elle-même (inchangé depuis
/// FaithFocus : renommer le package Android/bundle iOS est hors périmètre
/// de ce redesign, cf. plan). Toujours incluse dans la whitelist et non
/// désactivable par l'utilisateur, pour qu'il puisse toujours revenir dans
/// l'app depuis l'écran de blocage.
const String kVeillePackageId = 'com.faithfocus.faithfocus';

enum FocusSessionMode { schedule, timer }

enum FocusSessionStatus { idle, active }

/// Paramètres d'une session Focus telle que configurée par l'utilisateur.
class FocusSessionConfig {
  final FocusSessionMode mode;
  final List<String> whitelistedPackageIds;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final Duration? timerDuration;

  const FocusSessionConfig({
    required this.mode,
    required this.whitelistedPackageIds,
    this.scheduledStart,
    this.scheduledEnd,
    this.timerDuration,
  });
}

/// État observé par l'UI du mode Focus : soit inactif (avec un éventuel
/// message d'erreur de la dernière tentative de démarrage), soit actif avec
/// un temps restant mis à jour régulièrement par le contrôleur.
class FocusSessionState {
  final FocusSessionStatus status;
  final FocusSessionConfig? config;
  final DateTime? sessionEndTime;
  final Duration remaining;
  final String? errorMessage;

  const FocusSessionState.idle({this.errorMessage})
    : status = FocusSessionStatus.idle,
      config = null,
      sessionEndTime = null,
      remaining = Duration.zero;

  const FocusSessionState.active({
    required this.config,
    required this.sessionEndTime,
    required this.remaining,
  }) : status = FocusSessionStatus.active,
       errorMessage = null;

  bool get isActive => status == FocusSessionStatus.active;
}
