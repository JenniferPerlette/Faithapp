import 'package:flutter/material.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_theme.dart';
import 'choose_theme_screen.dart';

/// Onglet "Étude" de la barre de navigation. L'étude thématique n'a de sens
/// que pendant la période libre (elle demande 45 min de recherche puis une
/// rédaction) : verrouillée, cet onglet rappelle simplement l'heure de
/// déblocage plutôt que de proposer une action impossible à terminer.
class StudyTabScreen extends StatelessWidget {
  const StudyTabScreen({super.key, required this.locked, required this.profile});

  final bool locked;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;

    if (locked) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_outlined, size: 40, color: colors.harbor),
                const SizedBox(height: 16),
                Text(
                  "L'étude thématique t'attend",
                  textAlign: TextAlign.center,
                  style: AppTheme.newsreader(context, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  "Disponible dès ${profile.unlockTimeLabel}, une fois "
                  'libéré(e).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const ChooseThemeScreen();
  }
}
