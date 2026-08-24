import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Émet l'heure courante immédiatement puis chaque seconde — utilisé par
/// tout écran qui affiche un compte à rebours (Accueil verrouillé, minuteur
/// de recherche d'étude).
Stream<DateTime> _everySecond() async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}

final nowProvider = StreamProvider<DateTime>((ref) => _everySecond());
