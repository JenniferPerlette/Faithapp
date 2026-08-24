import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/dissertation.dart';
import 'dissertation_seed_data.dart';

/// Abstraction du stockage des dissertations, même principe que
/// [ProfileRepository] : Firestore si un compte réel existe, sinon un dépôt
/// local Hive.
abstract class DissertationRepository {
  /// Émet la liste des dissertations (plus récente d'abord) immédiatement,
  /// puis à chaque changement.
  Stream<List<Dissertation>> watchDissertations();

  Future<void> upsertDissertation(Dissertation dissertation);
}

/// Implémentation réelle, adossée à `users/{uid}/dissertations/{id}` (cf.
/// `firestore.rules` : lecture/écriture réservées au propriétaire).
class FirestoreDissertationRepository implements DissertationRepository {
  FirestoreDissertationRepository({
    required String uid,
    FirebaseFirestore? firestore,
  }) : _uid = uid,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final String _uid;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection('users')
      .doc(_uid)
      .collection('dissertations');

  @override
  Stream<List<Dissertation>> watchDissertations() {
    return _collection
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _fromFirestoreDoc(doc)).toList();
        });
  }

  @override
  Future<void> upsertDissertation(Dissertation dissertation) {
    final map = dissertation.toMap();
    map['submittedAt'] = Timestamp.fromDate(dissertation.submittedAt);
    map['updatedAt'] = Timestamp.fromDate(dissertation.updatedAt);
    return _collection.doc(dissertation.id).set(map);
  }

  Dissertation _fromFirestoreDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = Map<String, dynamic>.from(doc.data());
    final submittedAt = map['submittedAt'];
    final updatedAt = map['updatedAt'];
    map['submittedAt'] = submittedAt is Timestamp
        ? submittedAt.toDate()
        : DateTime.now();
    map['updatedAt'] = updatedAt is Timestamp
        ? updatedAt.toDate()
        : DateTime.now();
    return Dissertation.fromMap(doc.id, map);
  }
}

/// Dépôt local (Hive), seedé avec les 6 dissertations de démonstration du
/// design au premier lancement — voir `dissertation_seed_data.dart`.
class LocalDissertationRepository implements DissertationRepository {
  LocalDissertationRepository(this._box) {
    if (_box.isEmpty) {
      for (final dissertation in seedDissertations()) {
        unawaited(_box.put(dissertation.id, dissertation.toMap()));
      }
    }
  }

  final Box _box;
  final _controller = StreamController<List<Dissertation>>.broadcast();

  List<Dissertation> _readAll() {
    final all = _box.keys
        .map((key) {
          final map = Map<String, dynamic>.from(_box.get(key) as Map);
          return Dissertation.fromMap(key as String, map);
        })
        .toList();
    all.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return all;
  }

  @override
  Stream<List<Dissertation>> watchDissertations() async* {
    yield _readAll();
    yield* _controller.stream;
  }

  @override
  Future<void> upsertDissertation(Dissertation dissertation) async {
    await _box.put(dissertation.id, dissertation.toMap());
    _controller.add(_readAll());
  }
}

/// Fournit l'implémentation active. Doit être surchargé au démarrage de
/// l'app, comme [profileRepositoryProvider].
final dissertationRepositoryProvider = Provider<DissertationRepository>((
  ref,
) {
  throw UnimplementedError(
    'dissertationRepositoryProvider doit être surchargé au démarrage de '
    "l'application (FirestoreDissertationRepository ou "
    'LocalDissertationRepository)',
  );
});

/// Flux des dissertations courantes, pour une consommation directe
/// (`ref.watch`) dans les écrans.
final dissertationsStreamProvider = StreamProvider<List<Dissertation>>((ref) {
  return ref.watch(dissertationRepositoryProvider).watchDissertations();
});
