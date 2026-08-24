import 'package:flutter/material.dart';

import '../data/allowed_apps_catalog.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

/// Sélecteur des applications "alliées" (en plus de la Bible, toujours
/// incluse) — reprend l'écran "Modifier tes applications" du design.
/// Réutilisé tel quel par l'étape 3 de l'onboarding et par l'écran
/// "Modifier tes applications" du Profil.
class AllowedAppsPicker extends StatelessWidget {
  const AllowedAppsPicker({
    super.key,
    required this.selectedIds,
    required this.onChanged,
  });

  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  void _toggle(String id) {
    final next = List<String>.from(selectedIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      if (next.length >= UserProfile.kMaxAllowedApps) return;
      next.add(id);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;
    final brightness = theme.brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AppTile(
          label: AllowedAppsCatalog.bible.label,
          icon: AllowedAppsCatalog.bible.icon,
          accent: colors.harbor,
          trailing: Text(
            'Toujours autorisée',
            style: TextStyle(fontSize: 12, color: colors.harbor),
          ),
          selected: true,
          locked: true,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final app in AllowedAppsCatalog.selectable)
                _AppTile(
                  label: app.label,
                  icon: app.icon,
                  accent: app.accentFor(brightness) ?? colors.mahogany,
                  selected: selectedIds.contains(app.id),
                  onTap: () => _toggle(app.id),
                  showDivider: app != AllowedAppsCatalog.selectable.last,
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${selectedIds.length} / ${UserProfile.kMaxAllowedApps} sélectionnées',
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({
    required this.label,
    required this.icon,
    required this.accent,
    this.selected = false,
    this.locked = false,
    this.onTap,
    this.trailing,
    this.showDivider = false,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final bool selected;
  final bool locked;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor),
              ),
            )
          : null,
      child: Row(
        children: [
          if (locked)
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 15, color: theme.colorScheme.surface),
            )
          else
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? accent : Colors.transparent,
                border: Border.all(
                  color: selected ? accent : theme.dividerColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: selected
                  ? Icon(Icons.check, size: 14, color: theme.colorScheme.surface)
                  : null,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface),
            ),
          ),
          ?trailing,
        ],
      ),
    );

    if (locked || onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
