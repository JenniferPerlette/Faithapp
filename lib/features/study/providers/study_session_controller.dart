import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/dissertation_repository.dart';
import '../../../core/data/profile_repository.dart';
import '../../../core/models/dissertation.dart';
import '../data/study_themes.dart';

enum StudySessionPhase {
  /// Aucune étude en cours (état initial, ou après soumission).
  idle,

  /// Les 45 minutes de recherche, avant que la rédaction devienne
  /// obligatoire (cf. "avant la rédaction obligatoire" dans le design).
  researching,

  /// Le temps de recherche est écoulé : la dissertation doit être soumise
  /// pour continuer (écran "Écran verrouillé").
  writing,
}

class StudySessionState {
  final StudySessionPhase phase;
  final StudyTheme? theme;
  final DateTime? researchEndTime;
  final Duration remaining;

  const StudySessionState({
    required this.phase,
    required this.theme,
    required this.researchEndTime,
    required this.remaining,
  });

  const StudySessionState.idle()
    : phase = StudySessionPhase.idle,
      theme = null,
      researchEndTime = null,
      remaining = Duration.zero;

  StudySessionState copyWith({
    StudySessionPhase? phase,
    StudyTheme? theme,
    DateTime? researchEndTime,
    Duration? remaining,
  }) {
    return StudySessionState(
      phase: phase ?? this.phase,
      theme: theme ?? this.theme,
      researchEndTime: researchEndTime ?? this.researchEndTime,
      remaining: remaining ?? this.remaining,
    );
  }
}

/// Pilote le cycle de vie d'une étude thématique : sélection du thème,
/// décompte de recherche de 45 minutes, puis rédaction obligatoire avant
/// soumission (qui met à jour le profil : études terminées + temps rendu).
class StudySessionController extends Notifier<StudySessionState> {
  Timer? _ticker;

  @override
  StudySessionState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const StudySessionState.idle();
  }

  void startResearch(StudyTheme theme) {
    final end = DateTime.now().add(kStudyResearchDuration);
    state = StudySessionState(
      phase: StudySessionPhase.researching,
      theme: theme,
      researchEndTime: end,
      remaining: kStudyResearchDuration,
    );
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _onTick() {
    final current = state;
    final end = current.researchEndTime;
    if (current.phase != StudySessionPhase.researching || end == null) {
      _ticker?.cancel();
      return;
    }
    final remaining = end.difference(DateTime.now());
    if (remaining > Duration.zero) {
      state = current.copyWith(remaining: remaining);
      return;
    }
    _ticker?.cancel();
    state = current.copyWith(
      phase: StudySessionPhase.writing,
      remaining: Duration.zero,
    );
  }

  /// Soumet la dissertation : l'enregistre, met à jour les statistiques du
  /// profil (études terminées, temps rendu à Dieu — la durée de recherche
  /// vient d'être "rendue"), puis referme la session.
  Future<void> submit(String content) async {
    final theme = state.theme;
    if (theme == null) return;

    final now = DateTime.now();
    final dissertation = Dissertation(
      id: '${theme.id}-${now.microsecondsSinceEpoch}',
      themeId: theme.id,
      themeTitle: theme.title,
      content: content,
      submittedAt: now,
      updatedAt: now,
    );
    await ref.read(dissertationRepositoryProvider).upsertDissertation(dissertation);

    final profileRepository = ref.read(profileRepositoryProvider);
    final profile = await profileRepository.watchProfile().first;
    await profileRepository.updateProfile(
      profile.copyWith(
        studiesCompleted: profile.studiesCompleted + 1,
        hoursReturnedMinutes:
            profile.hoursReturnedMinutes + kStudyResearchDuration.inMinutes,
      ),
    );

    _ticker?.cancel();
    state = const StudySessionState.idle();
  }

  void cancel() {
    _ticker?.cancel();
    state = const StudySessionState.idle();
  }
}

final studySessionControllerProvider =
    NotifierProvider<StudySessionController, StudySessionState>(
      StudySessionController.new,
    );
