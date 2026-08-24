import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/ticker.dart';
import '../providers/study_session_controller.dart';
import 'write_dissertation_screen.dart';

/// "Recherche en cours" : les 45 minutes de recherche avant que la
/// rédaction ne devienne obligatoire. Volontairement impossible à quitter
/// en arrière (`PopScope`) : interrompre le minuteur viderait le principe
/// de l'étude.
class ResearchCountdownScreen extends ConsumerWidget {
  const ResearchCountdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;
    // Fait "ticker" cet écran à chaque seconde, indépendamment du minuteur
    // du contrôleur (qui ne se met à jour que sur son propre Timer).
    ref.watch(nowProvider);
    final session = ref.watch(studySessionControllerProvider);
    final studyTheme = session.theme;

    if (session.phase == StudySessionPhase.writing) {
      return const WriteDissertationScreen();
    }
    if (studyTheme == null) {
      // Session interrompue (ex: hot-reload) : retour à l'accueil plutôt
      // qu'un écran vide.
      return const Scaffold(body: SizedBox.shrink());
    }

    final minutes = session.remaining.inMinutes;
    final seconds = session.remaining.inSeconds.remainder(60);
    String two(int v) => v.toString().padLeft(2, '0');

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECHERCHE EN COURS',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: colors.mahogany,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Thème : ${studyTheme.title}',
                  style: AppTheme.newsreader(context, fontSize: 22),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${two(minutes)}:${two(seconds)}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 42,
                          fontWeight: FontWeight.w600,
                        ).copyWith(color: colors.mahogany),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'avant la rédaction obligatoire',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'VERSETS SUGGÉRÉS',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.8,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                for (final verse in studyTheme.suggestedVerses)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '« ${verse.text} »',
                          style: AppTheme.newsreader(context, fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          verse.reference,
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Center(
                  child: Text(
                    'Utilise ce temps pour chercher et réfléchir.',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
