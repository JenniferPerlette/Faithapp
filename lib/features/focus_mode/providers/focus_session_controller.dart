import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/app_blocker_channel.dart';
import '../models/focus_session_config.dart';

/// Fréquence de rafraîchissement du temps restant affiché à l'écran
/// "session active".
const Duration _tickInterval = Duration(seconds: 1);

/// Pilote le cycle de vie d'une session Focus : validation locale, appel au
/// natif via [AppBlockerChannel], puis suivi du temps restant.
///
/// Le décompte est purement local à l'UI (rafraîchissement visuel) : c'est
/// le natif (Tâches 4 et 6) qui reste responsable d'arrêter réellement le
/// blocage à échéance, y compris si l'app Flutter n'est pas au premier plan.
class FocusSessionController extends Notifier<FocusSessionState> {
  Timer? _ticker;

  @override
  FocusSessionState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const FocusSessionState.idle();
  }

  /// Démarre une session Focus. Demande d'abord les permissions natives,
  /// puis délègue le blocage à [AppBlockerChannel]. En cas de permission
  /// refusée ou d'argument invalide, l'état repasse à idle avec un message
  /// d'erreur explicite plutôt que de laisser l'UI dans un état incohérent.
  Future<void> startSession({
    required FocusSessionMode mode,
    required List<String> whitelistedPackageIds,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    Duration? timerDuration,
  }) async {
    final DateTime sessionEndTime;
    if (mode == FocusSessionMode.timer) {
      if (timerDuration == null) {
        state = const FocusSessionState.idle(
          errorMessage: 'Choisissez une durée de minuteur.',
        );
        return;
      }
      sessionEndTime = DateTime.now().add(timerDuration);
    } else {
      if (scheduledEnd == null) {
        state = const FocusSessionState.idle(
          errorMessage: 'Choisissez une heure de fin de plage horaire.',
        );
        return;
      }
      sessionEndTime = scheduledEnd;
    }

    final channel = ref.read(appBlockerChannelProvider);

    try {
      final granted = await channel.requestPermissions();
      if (!granted) {
        state = const FocusSessionState.idle(
          errorMessage:
              "Les permissions nécessaires au blocage n'ont pas été "
              'accordées.',
        );
        return;
      }

      await channel.startFocusSession(
        whitelistedPackageIds: whitelistedPackageIds,
        scheduledStart: scheduledStart,
        scheduledEnd: scheduledEnd,
        timerDuration: timerDuration,
      );
    } on ArgumentError catch (e) {
      state = FocusSessionState.idle(errorMessage: e.message?.toString());
      return;
    }

    state = FocusSessionState.active(
      config: FocusSessionConfig(
        mode: mode,
        whitelistedPackageIds: whitelistedPackageIds,
        scheduledStart: scheduledStart,
        scheduledEnd: scheduledEnd,
        timerDuration: timerDuration,
      ),
      sessionEndTime: sessionEndTime,
      remaining: sessionEndTime.difference(DateTime.now()),
    );
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(_tickInterval, (_) => _onTick());
  }

  void _onTick() {
    final currentState = state;
    final endTime = currentState.sessionEndTime;
    if (!currentState.isActive || endTime == null) {
      _ticker?.cancel();
      return;
    }

    final remaining = endTime.difference(DateTime.now());
    if (!remaining.isNegative && remaining > Duration.zero) {
      state = FocusSessionState.active(
        config: currentState.config,
        sessionEndTime: endTime,
        remaining: remaining,
      );
      return;
    }

    // Échéance atteinte : reflète l'arrêt du blocage côté UI. Le natif a sa
    // propre logique d'arrêt automatique (Tâches 4 et 6), cet appel garantit
    // seulement la cohérence visuelle et l'appel à stopFocusSession si l'app
    // Flutter était au premier plan pendant tout ce temps.
    unawaited(stopSession());
  }

  /// Arrête la session Focus, que ce soit sur action explicite de
  /// l'utilisateur ou sur expiration détectée par le ticker local.
  Future<void> stopSession() async {
    _ticker?.cancel();
    _ticker = null;
    final channel = ref.read(appBlockerChannelProvider);
    await channel.stopFocusSession();
    state = const FocusSessionState.idle();
  }
}

final focusSessionControllerProvider =
    NotifierProvider<FocusSessionController, FocusSessionState>(
      FocusSessionController.new,
    );
