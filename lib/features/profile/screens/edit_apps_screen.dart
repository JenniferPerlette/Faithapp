import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/profile_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/allowed_apps_picker.dart';

/// "Modifier tes applications" : réédition de la liste des applications
/// alliées depuis le Profil, en dehors de l'onboarding.
class EditAppsScreen extends ConsumerStatefulWidget {
  const EditAppsScreen({super.key});

  @override
  ConsumerState<EditAppsScreen> createState() => _EditAppsScreenState();
}

class _EditAppsScreenState extends ConsumerState<EditAppsScreen> {
  List<String>? _selectedIds;
  bool _saving = false;

  Future<void> _save() async {
    final selected = _selectedIds;
    if (selected == null || _saving) return;
    setState(() => _saving = true);
    final profileRepository = ref.read(profileRepositoryProvider);
    final profile = await profileRepository.watchProfile().first;
    await profileRepository.updateProfile(
      profile.copyWith(allowedAppIds: selected),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
          data: (profile) {
            final selectedIds = _selectedIds ?? profile.allowedAppIds;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modifier tes applications',
                    style: AppTheme.newsreader(context, fontSize: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "La Bible est toujours incluse. Choisis jusqu'à 3 autres.",
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AllowedAppsPicker(
                        selectedIds: selectedIds,
                        onChanged: (ids) => setState(() => _selectedIds = ids),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
