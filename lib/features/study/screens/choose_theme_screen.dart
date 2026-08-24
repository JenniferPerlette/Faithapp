import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/study_themes.dart';
import '../providers/study_session_controller.dart';
import 'research_countdown_screen.dart';

/// "Choisis un thème" : sélection du sujet de l'étude thématique, puis
/// lancement des 45 minutes de recherche.
class ChooseThemeScreen extends ConsumerStatefulWidget {
  const ChooseThemeScreen({super.key});

  @override
  ConsumerState<ChooseThemeScreen> createState() => _ChooseThemeScreenState();
}

class _ChooseThemeScreenState extends ConsumerState<ChooseThemeScreen> {
  StudyTheme _selected = studyThemes.first;

  void _start() {
    ref.read(studySessionControllerProvider.notifier).startResearch(_selected);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ResearchCountdownScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Étude thématique')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisis un thème',
                style: AppTheme.newsreader(context, fontSize: 26),
              ),
              const SizedBox(height: 6),
              Text(
                '45 minutes de recherche, puis une dissertation à rendre.',
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: studyThemes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = studyThemes[index];
                    final isSelected = item.id == _selected.id;
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => setState(() => _selected = item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? colors.harbor : theme.dividerColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.verseRefs,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: colors.harbor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Thème sélectionné : ${_selected.title}',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _start,
                  child: const Text('Commencer ma recherche · 45 min'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
