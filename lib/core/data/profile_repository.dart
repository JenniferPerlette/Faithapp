import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/user_profile.dart';

/// Abstraction du stockage du profil utilisateur, pour pouvoir basculer
/// entre Firestore (compte réel) et un dépôt local (pas de projet Firebase
/// configuré sur cette machine, cf. notes de `main.dart`) sans que le reste
/// de l'app le sache — même principe que `AppBlockerChannel`/
/// `FakeAppBlockerChannel`.
abstract class ProfileRepository {
  /// Émet le profil courant immédiatement, puis à chaque mise à jour. Crée
  /// un profil par défaut si aucun n'existe encore (ne devrait arriver
  /// qu'en cas d'accès direct hors onboarding).
  Stream<UserProfile> watchProfile();

  Future<void> updateProfile(UserProfile profile);
}

/// Implémentation réelle, adossée à `users/{uid}` (cf. `firestore.rules` :
/// lecture/écriture réservées au propriétaire).
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({
    required String uid,
    FirebaseFirestore? firestore,
  }) : _uid = uid,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final String _uid;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('users').doc(_uid);

  @override
  Stream<UserProfile> watchProfile() {
    return _doc.snapshots().asyncMap((snapshot) async {
      final data = snapshot.data();
      if (data == null) {
        final seeded = UserProfile.seedDemo();
        await _doc.set(_toFirestoreMap(seeded));
        return seeded;
      }
      return _fromFirestoreMap(data);
    });
  }

  @override
  Future<void> updateProfile(UserProfile profile) {
    return _doc.set(_toFirestoreMap(profile), SetOptions(merge: true));
  }

  Map<String, dynamic> _toFirestoreMap(UserProfile profile) {
    final map = profile.toMap();
    map['createdAt'] = Timestamp.fromDate(profile.createdAt);
    final lastActivityDate = profile.lastActivityDate;
    map['lastActivityDate'] = lastActivityDate == null
        ? null
        : Timestamp.fromDate(lastActivityDate);
    return map;
  }

  UserProfile _fromFirestoreMap(Map<String, dynamic> data) {
    final map = Map<String, dynamic>.from(data);
    final createdAt = map['createdAt'];
    map['createdAt'] = createdAt is Timestamp
        ? createdAt.toDate()
        : DateTime.now();
    final lastActivityDate = map['lastActivityDate'];
    map['lastActivityDate'] = lastActivityDate is Timestamp
        ? lastActivityDate.toDate()
        : null;
    return UserProfile.fromMap(map);
  }
}

/// Dépôt local (Hive) utilisé quand Firebase n'est pas configuré sur cette
/// machine (pas de `firebase_options.dart`/`google-services.json` — voir
/// `main.dart`). Seedé avec le profil de démonstration du design ("Léa M.")
/// au premier lancement, pour que l'app reste démontrable de bout en bout.
class LocalProfileRepository implements ProfileRepository {
  LocalProfileRepository(this._box) {
    final stored = _box.get(_key);
    _current = stored != null
        ? UserProfile.fromMap(Map<String, dynamic>.from(stored as Map))
        : UserProfile.seedDemo();
    if (stored == null) {
      unawaited(_persist(_current));
    }
  }

  static const _key = 'profile';
  final Box _box;
  late UserProfile _current;
  final _controller = StreamController<UserProfile>.broadcast();

  @override
  Stream<UserProfile> watchProfile() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    _current = profile;
    await _persist(profile);
    _controller.add(profile);
  }

  Future<void> _persist(UserProfile profile) {
    return _box.put(_key, profile.toMap());
  }
}

/// Fournit l'implémentation active. Doit être surchargé au démarrage de
/// l'app (`main.dart`), selon que Firebase a pu être initialisé ou non —
/// volontairement pas de valeur par défaut, pour qu'un oubli de
/// configuration ne passe pas inaperçu (même convention que
/// `appBlockerChannelProvider`).
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError(
    'profileRepositoryProvider doit être surchargé au démarrage de '
    "l'application (FirestoreProfileRepository ou LocalProfileRepository)",
  );
});

/// Flux du profil courant, pour une consommation directe (`ref.watch`) dans
/// les écrans.
final profileStreamProvider = StreamProvider<UserProfile>((ref) {
  return ref.watch(profileRepositoryProvider).watchProfile();
});
