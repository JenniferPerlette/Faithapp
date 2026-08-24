import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Puces de progression des 3 étapes de l'onboarding (après le splash),
/// reprises telles quelles du design (puce pleine Mistelle = étape
/// courante).
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({super.key, required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.veilleColors;
    final inactive = Theme.of(context).dividerColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == activeIndex ? colors.mistelle : inactive,
              ),
            ),
          ),
      ],
    );
  }
}
