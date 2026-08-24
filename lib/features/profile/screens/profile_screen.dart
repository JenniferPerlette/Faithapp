import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/dissertation_repository.dart';
import '../../../core/data/onboarding_repository.dart';
import '../../../core/data/profile_repository.dart';
import '../../../core/models/dissertation.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_theme.dart';
import 'dissertations_list_screen.dart';
import 'edit_apps_screen.dart';

/// Profil : identité, statistiques, dissertations récentes, réglages.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('$error')),
      data: (profile) => _ProfileBody(profile: profile),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  Future<void> _pickUnlockTime(BuildContext context, WidgetRef ref) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: profile.unlockTimeMinutes ~/ 60,
        minute: profile.unlockTimeMinutes % 60,
      ),
    );
    if (picked == null) return;
    await ref.read(profileRepositoryProvider).updateProfile(
      profile.copyWith(unlockTimeMinutes: picked.hour * 60 + picked.minute),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          "Tu reviendras à l'écran de bienvenue et pourras reconfigurer "
          'Veille.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(onboardingRepositoryProvider).reset();
      ref.read(onboardingCompleteProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;
    final dissertationsAsync = ref.watch(dissertationsStreamProvider);
    final daysSince = DateTime.now().difference(profile.createdAt).inDays;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.cardTheme.color,
                child: Icon(Icons.person_outline, color: colors.harbor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: AppTheme.newsreader(context, fontSize: 20),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'En veille depuis $daysSince jours',
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _StatTile(
                value: '${profile.currentStreakDays}',
                label: 'jours de suite',
                color: colors.mahogany,
              ),
              const SizedBox(width: 10),
              _StatTile(
                value: '${profile.studiesCompleted}',
                label: 'études terminées',
                color: colors.harbor,
              ),
              const SizedBox(width: 10),
              _StatTile(
                value: profile.hoursReturnedLabel,
                label: 'temps rendu à Dieu',
                color: colors.cognac,
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            'MES DISSERTATIONS',
            style: TextStyle(fontSize: 12, letterSpacing: 0.8, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          dissertationsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => Text('$error'),
            data: (dissertations) => _DissertationsPreview(dissertations: dissertations.take(3).toList(), hasMore: dissertations.length > 3),
          ),
          const SizedBox(height: 26),
          Text(
            'RÉGLAGES',
            style: TextStyle(fontSize: 12, letterSpacing: 0.8, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _SettingsRow(
                  label: 'Heure de déblocage',
                  value: profile.unlockTimeLabel,
                  onTap: () => _pickUnlockTime(context, ref),
                ),
                _SettingsRow(
                  label: 'Applications autorisées',
                  value: '${profile.allowedAppIds.length} · Modifier',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditAppsScreen()),
                  ),
                ),
                _SettingsRow(
                  label: 'Notifications',
                  value: profile.notificationsEnabled ? 'Activées' : 'Désactivées',
                  onTap: () => ref.read(profileRepositoryProvider).updateProfile(
                    profile.copyWith(notificationsEnabled: !profile.notificationsEnabled),
                  ),
                ),
                _SettingsRow(
                  label: 'Mode sombre',
                  value: profile.darkModeEnabled ? 'Activé' : 'Désactivé',
                  onTap: () => ref.read(profileRepositoryProvider).updateProfile(
                    profile.copyWith(darkModeEnabled: !profile.darkModeEnabled),
                  ),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => _confirmSignOut(context, ref),
              child: Text('Se déconnecter', style: TextStyle(color: colors.mahogany)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _DissertationsPreview extends StatelessWidget {
  const _DissertationsPreview({required this.dissertations, required this.hasMore});

  final List<Dissertation> dissertations;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;
    if (dissertations.isEmpty) {
      return Text(
        "Aucune dissertation pour l'instant — lance une étude pendant ta "
        'période libre.',
        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final dissertation in dissertations)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dissertation.themeTitle,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                  Text('Modifier', style: TextStyle(fontSize: 12, color: colors.harbor)),
                ],
              ),
            ),
          if (hasMore)
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DissertationsListScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('Voir plus', style: TextStyle(fontSize: 13, color: colors.harbor)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.isLast = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: isLast
            ? null
            : BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
            Text(value, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
