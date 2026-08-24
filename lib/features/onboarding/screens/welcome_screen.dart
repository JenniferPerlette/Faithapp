import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/onboarding_dots.dart';
import '../widgets/veille_mark.dart';

/// Étape 1/3 : logo + tagline. Toute la surface est cliquable pour avancer
/// (en plus du geste de balayage du `PageView` parent).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onNext,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const VeilleMark(size: 64),
                const SizedBox(height: 22),
                Text(
                  'Veille',
                  style: AppTheme.newsreader(
                    context,
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Reste sur le droit chemin,\nune heure à la fois.',
                  textAlign: TextAlign.center,
                  style: AppTheme.newsreader(
                    context,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                const OnboardingDots(count: 3, activeIndex: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
