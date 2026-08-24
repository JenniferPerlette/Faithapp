import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Le petit repère visuel du design "Veille" : un anneau (Harbor) et un
/// disque décalé (Mahogany par défaut) — reproduit avec des `Container`
/// plutôt qu'une image, pour rester fidèle au design sans avoir à générer
/// d'assets.
class VeilleMark extends StatelessWidget {
  const VeilleMark({super.key, this.size = 64, this.diskColor});

  final double size;
  final Color? diskColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.veilleColors;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.harbor, width: 2),
              ),
            ),
          ),
          Positioned(
            top: size * 0.094,
            left: size * 0.344,
            child: Container(
              width: size * 0.6875,
              height: size * 0.6875,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: diskColor ?? colors.mahogany,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
