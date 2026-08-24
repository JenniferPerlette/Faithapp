import 'package:flutter/material.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/onboarding_dots.dart';
import '../widgets/veille_mark.dart';

/// Étape 3/3 : "Le reste attend son heure" — l'écran du design est un écran
/// d'intro pure ; on y ajoute la seule chose nécessaire pour que
/// l'onboarding produise une configuration utilisable : le choix de
/// l'heure de déblocage (un simple chip tappable ouvrant le time picker
/// natif Flutter, par défaut 18:00 comme dans le design).
class ReadyScreen extends StatelessWidget {
  const ReadyScreen({
    super.key,
    required this.unlockTimeMinutes,
    required this.onUnlockTimeChanged,
    required this.onFinish,
  });

  final int unlockTimeMinutes;
  final ValueChanged<int> onUnlockTimeChanged;
  final VoidCallback onFinish;

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: unlockTimeMinutes ~/ 60,
        minute: unlockTimeMinutes % 60,
      ),
    );
    if (picked != null) {
      onUnlockTimeChanged(picked.hour * 60 + picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VeilleMark(size: 64, diskColor: colors.mistelle),
              const SizedBox(height: 22),
              Text(
                'Le reste attend son heure',
                textAlign: TextAlign.center,
                style: AppTheme.newsreader(context, fontSize: 26),
              ),
              const SizedBox(height: 8),
              Text(
                'Tout le reste se verrouille\njusqu\'à l\'heure que tu fixes.',
                textAlign: TextAlign.center,
                style: AppTheme.newsreader(
                  context,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () => _pickTime(context),
                icon: const Icon(Icons.schedule_outlined, size: 18),
                label: Text('Déblocage à ${formatMinutesAsHm(unlockTimeMinutes)}'),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onFinish,
                  child: const Text('Commencer'),
                ),
              ),
              const SizedBox(height: 16),
              const OnboardingDots(count: 3, activeIndex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
