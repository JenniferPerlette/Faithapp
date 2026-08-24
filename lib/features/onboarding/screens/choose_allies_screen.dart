import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/allowed_apps_picker.dart';
import '../widgets/onboarding_dots.dart';
import '../widgets/veille_mark.dart';

/// Étape 2/3 : "Choisis tes 3 alliées" — combine l'écran d'intro du design
/// avec le sélecteur interactif (repris de l'écran "Modifier tes
/// applications"), pour que l'onboarding aboutisse à une vraie
/// configuration plutôt qu'à un simple écran marketing.
class ChooseAlliesScreen extends StatelessWidget {
  const ChooseAlliesScreen({
    super.key,
    required this.selectedIds,
    required this.onChanged,
    required this.onNext,
  });

  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              VeilleMark(size: 56, diskColor: colors.cognac),
              const SizedBox(height: 18),
              Text(
                'Choisis tes 3 alliées',
                textAlign: TextAlign.center,
                style: AppTheme.newsreader(context, fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                "La Bible reste toujours ouverte. Tu ajoutes jusqu'à 3 "
                'applications essentielles.',
                textAlign: TextAlign.center,
                style: AppTheme.newsreader(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  child: AllowedAppsPicker(
                    selectedIds: selectedIds,
                    onChanged: onChanged,
                  ),
                ),
              ),
              const OnboardingDots(count: 3, activeIndex: 1),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onNext,
                  child: const Text('Continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
