import 'dart:io';

import 'package:faithfocus/core/data/dissertation_repository.dart';
import 'package:faithfocus/core/data/profile_repository.dart';
import 'package:faithfocus/core/models/dissertation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('veille_local_repo_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  group('LocalProfileRepository', () {
    test('seeds the demo profile on first run', () async {
      final box = await Hive.openBox('profile_box');
      final repository = LocalProfileRepository(box);

      final profile = await repository.watchProfile().first;
      expect(profile.displayName, 'Léa M.');
      expect(profile.currentStreakDays, 24);
    });

    test('persists updates across repository instances', () async {
      final box = await Hive.openBox('profile_box');
      final repository = LocalProfileRepository(box);
      final seeded = await repository.watchProfile().first;

      await repository.updateProfile(
        seeded.copyWith(displayName: 'Nouveau nom'),
      );

      final reopened = LocalProfileRepository(box);
      final reloaded = await reopened.watchProfile().first;
      expect(reloaded.displayName, 'Nouveau nom');
    });
  });

  group('LocalDissertationRepository', () {
    test('seeds the 6 demo dissertations on first run', () async {
      final box = await Hive.openBox('dissertations_box');
      final repository = LocalDissertationRepository(box);

      final dissertations = await repository.watchDissertations().first;
      expect(dissertations, hasLength(6));
      expect(
        dissertations.map((d) => d.themeTitle),
        contains('La patience'),
      );
    });

    test('upsertDissertation adds a new entry without duplicating others',
        () async {
      final box = await Hive.openBox('dissertations_box');
      final repository = LocalDissertationRepository(box);
      await repository.watchDissertations().first;

      final entriesBefore = box.length;
      final now = DateTime.now();
      await repository.upsertDissertation(
        Dissertation(
          id: 'custom-1',
          themeId: 'foi',
          themeTitle: 'La foi',
          content: 'Une nouvelle réflexion.',
          submittedAt: now,
          updatedAt: now,
        ),
      );
      final dissertations = await repository.watchDissertations().first;

      expect(dissertations, hasLength(7));
      expect(box.length, entriesBefore + 1);
    });
  });
}
