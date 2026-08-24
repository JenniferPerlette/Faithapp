import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nombre maximum d'identifiants de packages autorisés dans la whitelist.
/// Borne volontairement basse : au-delà, il s'agit très probablement d'un
/// appel malformé plutôt que d'un usage légitime (OWASP Mobile M4 —
/// Improper Input Validation).
const int kMaxWhitelistSize = 50;

/// Durée maximale acceptée pour un minuteur de session Focus.
const Duration kMaxTimerDuration = Duration(hours: 24);

/// Interface commune pour piloter le blocage natif d'applications, quelle
/// que soit la plateforme (Android/iOS) ou l'implémentation (réelle/fake).
abstract class AppBlockerChannel {
  Future<bool> requestPermissions();

  Future<void> startFocusSession({
    required List<String> whitelistedPackageIds,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    Duration? timerDuration,
  });

  Future<void> stopFocusSession();

  Stream<String> get onBlockedAppAttempt;
}

/// Valide les paramètres d'une session Focus avant tout envoi au natif ou
/// traitement local. Lève une [ArgumentError] explicite en cas de valeur
/// hors plage, plutôt que de laisser le natif échouer silencieusement.
void validateFocusSessionArgs({
  required List<String> whitelistedPackageIds,
  Duration? timerDuration,
}) {
  if (whitelistedPackageIds.length > kMaxWhitelistSize) {
    throw ArgumentError(
      'whitelistedPackageIds dépasse la taille maximale autorisée '
      '($kMaxWhitelistSize)',
    );
  }
  if (whitelistedPackageIds.any((id) => id.trim().isEmpty)) {
    throw ArgumentError(
      'whitelistedPackageIds ne doit pas contenir de chaîne vide',
    );
  }
  if (timerDuration != null) {
    if (timerDuration.isNegative || timerDuration == Duration.zero) {
      throw ArgumentError('timerDuration doit être strictement positif');
    }
    if (timerDuration > kMaxTimerDuration) {
      throw ArgumentError(
        'timerDuration dépasse la durée maximale autorisée '
        '($kMaxTimerDuration)',
      );
    }
  }
}

/// Implémentation réelle, adossée au code natif Android/iOS (Tâches 4 et 6)
/// via `MethodChannel`/`EventChannel`.
class MethodChannelAppBlockerChannel implements AppBlockerChannel {
  MethodChannelAppBlockerChannel({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel =
           methodChannel ?? const MethodChannel('com.faithfocus/blocker'),
       _eventChannel =
           eventChannel ??
           const EventChannel('com.faithfocus/blocker_events');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  @override
  Future<bool> requestPermissions() async {
    final granted = await _methodChannel.invokeMethod<bool>(
      'requestPermissions',
    );
    return granted ?? false;
  }

  @override
  Future<void> startFocusSession({
    required List<String> whitelistedPackageIds,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    Duration? timerDuration,
  }) async {
    validateFocusSessionArgs(
      whitelistedPackageIds: whitelistedPackageIds,
      timerDuration: timerDuration,
    );

    await _methodChannel.invokeMethod('startFocusSession', {
      'whitelistedPackageIds': whitelistedPackageIds,
      'scheduledStart': scheduledStart?.toIso8601String(),
      'scheduledEnd': scheduledEnd?.toIso8601String(),
      'timerDurationSeconds': timerDuration?.inSeconds,
    });
  }

  @override
  Future<void> stopFocusSession() async {
    await _methodChannel.invokeMethod('stopFocusSession');
  }

  @override
  Stream<String> get onBlockedAppAttempt {
    return _eventChannel.receiveBroadcastStream().map(
      (event) => event as String,
    );
  }
}

/// Implémentation fictive n'appelant aucun code natif, pour développer et
/// tester l'UI du mode Focus indépendamment des plateformes Android/iOS.
class FakeAppBlockerChannel implements AppBlockerChannel {
  final _blockedAppAttemptController = StreamController<String>.broadcast();

  bool permissionsGranted = true;

  @override
  Future<bool> requestPermissions() async => permissionsGranted;

  @override
  Future<void> startFocusSession({
    required List<String> whitelistedPackageIds,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    Duration? timerDuration,
  }) async {
    validateFocusSessionArgs(
      whitelistedPackageIds: whitelistedPackageIds,
      timerDuration: timerDuration,
    );
  }

  @override
  Future<void> stopFocusSession() async {}

  @override
  Stream<String> get onBlockedAppAttempt =>
      _blockedAppAttemptController.stream;

  /// Simule la détection d'une tentative d'ouverture d'app non whitelistée,
  /// pour piloter l'UI en développement/tests sans natif.
  void simulateBlockedAppAttempt(String packageId) {
    _blockedAppAttemptController.add(packageId);
  }

  void dispose() {
    _blockedAppAttemptController.close();
  }
}

/// Fournit l'implémentation active d'[AppBlockerChannel]. Doit être
/// surchargé explicitement (via `ProviderScope(overrides: [...])`) par la
/// vraie implémentation ou par [FakeAppBlockerChannel], selon le flavor de
/// build — volontairement pas de valeur par défaut pour éviter qu'un oubli
/// de configuration passe inaperçu.
final appBlockerChannelProvider = Provider<AppBlockerChannel>((ref) {
  throw UnimplementedError(
    'appBlockerChannelProvider doit être surchargé au démarrage de '
    'l\'application (MethodChannelAppBlockerChannel ou FakeAppBlockerChannel)',
  );
});

/// Identifiant de l'application dont l'ouverture vient d'être tentée
/// pendant la période verrouillée — cf. `BlockedAppScreen`. En
/// développement/tests, `FakeAppBlockerChannel.simulateBlockedAppAttempt`
/// permet de déclencher ce flux sans natif.
final blockedAppAttemptProvider = StreamProvider<String>((ref) {
  return ref.watch(appBlockerChannelProvider).onBlockedAppAttempt;
});
