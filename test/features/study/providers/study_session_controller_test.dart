import 'package:faithfocus/core/data/dissertation_repository.dart';
import 'package:faithfocus/core/data/profile_repository.dart';
import 'package:faithfocus/core/models/user_profile.dart';
import 'package:faithfocus/features/study/data/study_themes.dart';
import 'package:faithfocus/features/study/providers/study_session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_doubles.dart';

void main() {
  late FakeProfileRepository profileRepo;
  late FakeDissertationRepository dissertationRepo;
  late ProviderContainer container;

  setUp(() {
    profileRepo = FakeProfileRepository(
      UserProfile.initial(
        displayName: 'Ami(e)',
        unlockTimeMinutes: 18 * 60,
        allowedAppIds: const [],
      ),
    );
    dissertationRepo = FakeDissertationRepository();
    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(profileRepo),
        dissertationRepositoryProvider.overrideWithValue(dissertationRepo),
      ],
    );
    addTearDown(container.dispose);
  });

  test(
    'startResearch moves to the researching phase with a 45 minute '
    'countdown',
    () {
      final controller = container.read(
        studySessionControllerProvider.notifier,
      );
      controller.startResearch(studyThemes.first);

      final state = container.read(studySessionControllerProvider);
      expect(state.phase, StudySessionPhase.researching);
      expect(state.theme, studyThemes.first);
      expect(state.remaining, kStudyResearchDuration);
    },
  );

  test(
    'submit saves the dissertation, updates profile stats, and resets to '
    'idle',
    () async {
      final controller = container.read(
        studySessionControllerProvider.notifier,
      );
      controller.startResearch(studyThemes.first);

      await controller.submit('Ma réflexion sur ce thème.');

      expect(dissertationRepo.items, hasLength(1));
      expect(dissertationRepo.items.single.themeId, studyThemes.first.id);
      expect(
        dissertationRepo.items.single.content,
        'Ma réflexion sur ce thème.',
      );

      expect(profileRepo.current.studiesCompleted, 1);
      expect(
        profileRepo.current.hoursReturnedMinutes,
        kStudyResearchDuration.inMinutes,
      );

      final state = container.read(studySessionControllerProvider);
      expect(state.phase, StudySessionPhase.idle);
    },
  );

  test('cancel resets to idle without saving anything', () {
    final controller = container.read(
      studySessionControllerProvider.notifier,
    );
    controller.startResearch(studyThemes.first);
    controller.cancel();

    final state = container.read(studySessionControllerProvider);
    expect(state.phase, StudySessionPhase.idle);
    expect(dissertationRepo.items, isEmpty);
  });
}
