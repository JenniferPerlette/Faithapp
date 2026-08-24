import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Sait si l'utilisateur a déjà terminé l'onboarding sur cet appareil.
/// Volontairement local (Hive) même quand Firestore est disponible : c'est
/// une préférence d'appareil ("ne plus jamais montrer ces écrans ici"), pas
/// une donnée de compte à synchroniser.
class OnboardingRepository {
  OnboardingRepository(this._box);

  static const _key = 'onboardingComplete';
  final Box _box;

  bool get isComplete => _box.get(_key, defaultValue: false) as bool;

  Future<void> markComplete() => _box.put(_key, true);

  /// "Se déconnecter" depuis le Profil : l'app n'a pas de vrai système de
  /// comptes multiples (auth anonyme uniquement), donc "se déconnecter"
  /// remet l'utilisateur devant l'onboarding pour reconfigurer Veille.
  Future<void> reset() => _box.put(_key, false);
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  throw UnimplementedError(
    'onboardingRepositoryProvider doit être surchargé au démarrage de '
    "l'application",
  );
});

/// État réactif "onboarding terminé", pour que `AppRoot` puisse observer un
/// changement (`OnboardingRepository.isComplete` est un simple getter Hive,
/// pas un flux Riverpod). Initialisé au démarrage depuis
/// [OnboardingRepository.isComplete], puis mis à true par
/// `OnboardingFlow._finish()`.
class OnboardingCompleteNotifier extends Notifier<bool> {
  OnboardingCompleteNotifier([this._initial]);

  /// `null` seulement pour le cas "non surchargé" (erreur explicite, comme
  /// les autres providers d'infrastructure) ; `main.dart` fournit toujours
  /// une valeur initiale réelle, lue depuis [OnboardingRepository.isComplete].
  final bool? _initial;

  @override
  bool build() {
    final initial = _initial;
    if (initial == null) {
      throw UnimplementedError(
        'onboardingCompleteProvider doit être surchargé au démarrage de '
        "l'application",
      );
    }
    return initial;
  }

  void markComplete() => state = true;

  void reset() => state = false;
}

final onboardingCompleteProvider =
    NotifierProvider<OnboardingCompleteNotifier, bool>(
      OnboardingCompleteNotifier.new,
    );
