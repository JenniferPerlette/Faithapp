import 'package:flutter/material.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_theme.dart';
import '../../study/screens/choose_theme_screen.dart';

/// Accueil pendant la période libre : rappel de l'heure de reverrouillage
/// et mise en avant de l'étude thématique.
class HomeUnlockedScreen extends StatelessWidget {
  const HomeUnlockedScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        children: [
          Text(
            'Tu es libre',
            style: AppTheme.newsreader(
              context,
              fontSize: 15,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            "jusqu'à ${profile.unlockTimeLabel}",
            style: AppTheme.newsreader(context, fontSize: 28),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.harbor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toutes les apps sont ouvertes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Le verrouillage reprend à minuit',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOUVEAU',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: colors.mahogany,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Étude thématique',
                  style: AppTheme.newsreader(context, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  '45 minutes pour explorer un thème biblique et écrire '
                  'une courte dissertation.',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChooseThemeScreen(),
                      ),
                    ),
                    child: const Text('Lancer une étude'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
