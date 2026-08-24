import 'package:firebase_auth/firebase_auth.dart';

/// Authentification Veille : le design ne comporte aucun écran de
/// connexion/inscription (le profil "Léa M." apparaît déjà rempli), donc
/// l'auth anonyme suffit — elle donne juste un `uid` stable pour que les
/// Security Rules Firestore ("propriétaire uniquement", cf.
/// `firestore.rules`) puissent s'appliquer.
class AuthService {
  const AuthService(this._auth);

  final FirebaseAuth _auth;

  /// Connecte l'utilisateur de façon anonyme si nécessaire et renvoie son
  /// uid. Idempotent : si une session anonyme existe déjà (persistée par le
  /// SDK Firebase), elle est réutilisée plutôt que d'en recréer une.
  Future<String> signInAnonymously() async {
    final current = _auth.currentUser;
    if (current != null) {
      return current.uid;
    }
    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw StateError(
        "signInAnonymously a réussi sans renvoyer d'utilisateur.",
      );
    }
    return user.uid;
  }
}
