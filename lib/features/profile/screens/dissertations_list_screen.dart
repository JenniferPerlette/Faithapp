import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/dissertation_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatting.dart';
import '../../study/screens/write_dissertation_screen.dart';

/// Liste complète des dissertations soumises ("Mes dissertations" du
/// design, accessible depuis "Voir plus" sur le Profil).
class DissertationsListScreen extends ConsumerWidget {
  const DissertationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;
    final dissertationsAsync = ref.watch(dissertationsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: dissertationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
          data: (dissertations) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes dissertations',
                  style: AppTheme.newsreader(context, fontSize: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  '${dissertations.length} dissertations soumises',
                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      itemCount: dissertations.length,
                      separatorBuilder: (_, _) => Divider(height: 1, color: theme.dividerColor),
                      itemBuilder: (context, index) {
                        final dissertation = dissertations[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text(
                            dissertation.themeTitle,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                          ),
                          subtitle: Text(
                            '${formatFrenchShortDate(dissertation.submittedAt)} · '
                            '${dissertation.wordCount} mots',
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                          ),
                          trailing: Text('Modifier', style: TextStyle(fontSize: 12, color: colors.harbor)),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WriteDissertationScreen(existing: dissertation),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
