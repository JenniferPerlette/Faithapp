import 'dart:async';

import 'package:faithfocus/core/data/dissertation_repository.dart';
import 'package:faithfocus/core/data/profile_repository.dart';
import 'package:faithfocus/core/models/dissertation.dart';
import 'package:faithfocus/core/models/user_profile.dart';

/// In-memory test doubles for the repository interfaces, shared across
/// widget and provider tests so they don't need Firestore or Hive.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository(this._current);

  UserProfile _current;
  final _controller = StreamController<UserProfile>.broadcast();

  UserProfile get current => _current;

  @override
  Stream<UserProfile> watchProfile() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    _current = profile;
    _controller.add(profile);
  }
}

class FakeDissertationRepository implements DissertationRepository {
  List<Dissertation> _items = const [];
  final _controller = StreamController<List<Dissertation>>.broadcast();

  List<Dissertation> get items => _items;

  @override
  Stream<List<Dissertation>> watchDissertations() async* {
    yield _items;
    yield* _controller.stream;
  }

  @override
  Future<void> upsertDissertation(Dissertation dissertation) async {
    _items = [
      ..._items.where((d) => d.id != dissertation.id),
      dissertation,
    ];
    _controller.add(_items);
  }
}
