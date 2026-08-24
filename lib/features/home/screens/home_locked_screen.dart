import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/allowed_apps_catalog.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../core/utils/lock_schedule.dart';
import '../../../core/utils/ticker.dart';
import '../../profile/screens/edit_apps_screen.dart';
import '../data/daily_verses.dart';

/// Accueil pendant la période verrouillée : compte à rebours jusqu'au
/// déblocage, applications autorisées, verset du jour.
class HomeLockedScreen extends ConsumerWidget {
  const HomeLockedScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final remaining = remainingUntilUnlock(now, profile.unlockTimeMinutes);
    final verse = dailyVerseFor(now);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        children: [
          Text(
            'Bonjour',
            style: AppTheme.newsreader(
              context,
              fontSize: 15,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            formatFrenchLongDate(now),
            style: AppTheme.newsreader(context, fontSize: 26),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 22),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VERROUILLÉ',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 1.2,
                    color: colors.harbor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.unlockTimeLabel,
                  style: AppTheme.newsreader(context, fontSize: 44),
                ),
                Text(
                  'Encore ${formatDurationHm(remaining)} avant le déblocage',
                  style: TextStyle(fontSize: 14, color: colors.harbor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'APPLICATIONS AUTORISÉES',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 0.8,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _AppChip(
                label: AllowedAppsCatalog.bible.label,
                color: colors.harbor,
              ),
              for (final id in profile.allowedAppIds)
                if (AllowedAppsCatalog.byId(id) case final app?)
                  _AppChip(
                    label: app.label,
                    color: app.accentFor(theme.brightness) ?? colors.mahogany,
                  ),
              ActionChip(
                label: const Text('Modifier'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditAppsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VERSET DU JOUR',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.8,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '« ${verse.text} »',
                  style: AppTheme.newsreader(context, fontSize: 17, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 10),
                Text(
                  verse.reference,
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppChip extends StatelessWidget {
  const _AppChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
