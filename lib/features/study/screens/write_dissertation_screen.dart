import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/dissertation_repository.dart';
import '../../../core/models/dissertation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatting.dart';
import '../providers/study_session_controller.dart';

/// Rédaction d'une dissertation. Deux usages :
/// - [existing] == null : rédaction obligatoire de fin d'étude ("Écran
///   verrouillé" du design) — aucune sortie possible avant soumission.
/// - [existing] != null : modification d'une dissertation passée, depuis le
///   Profil ("Modifier : {titre}") — Annuler/Enregistrer classiques.
class WriteDissertationScreen extends ConsumerStatefulWidget {
  const WriteDissertationScreen({super.key, this.existing});

  final Dissertation? existing;

  @override
  ConsumerState<WriteDissertationScreen> createState() =>
      _WriteDissertationScreenState();
}

class _WriteDissertationScreenState
    extends ConsumerState<WriteDissertationScreen> {
  late final TextEditingController _controller;
  bool _saving = false;

  bool get _isEditingExisting => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existing?.content ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitForcedWrite() async {
    if (_controller.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);
    await ref
        .read(studySessionControllerProvider.notifier)
        .submit(_controller.text.trim());
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _saveEdit() async {
    final existing = widget.existing;
    if (existing == null || _controller.text.trim().isEmpty || _saving) {
      return;
    }
    setState(() => _saving = true);
    await ref.read(dissertationRepositoryProvider).upsertDissertation(
      existing.copyWith(
        content: _controller.text.trim(),
        updatedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditingExisting) return _buildEditMode(context);
    return _buildForcedWriteMode(context);
  }

  Widget _buildForcedWriteMode(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.veilleColors;
    final session = ref.watch(studySessionControllerProvider);
    final studyTheme = session.theme;
    final canSubmit = _controller.text.trim().isNotEmpty && !_saving;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.blockedBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ÉCRAN VERROUILLÉ',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                    color: colors.mahogany,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Le temps de recherche est terminé.',
                  style: AppTheme.newsreader(
                    context,
                    fontSize: 22,
                    color: colors.blockedText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Écris ta dissertation sur « ${studyTheme?.title ?? ''} » "
                  "pour continuer. Rien d'autre n'est accessible tant "
                  "qu'elle n'est pas soumise.",
                  style: TextStyle(fontSize: 14, color: colors.blockedText, height: 1.5),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: (_) => setState(() {}),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Écris ici ce qui t\'a marqué, à partir de '
                            'cette méditation…',
                      ),
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canSubmit ? _submitForcedWrite : null,
                    child: const Text('Soumettre ma dissertation'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditMode(BuildContext context) {
    final theme = Theme.of(context);
    final existing = widget.existing!;
    return Scaffold(
      appBar: AppBar(title: const Text('Mes dissertations')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifier : ${existing.themeTitle}',
                style: AppTheme.newsreader(context, fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(
                'Soumise le ${formatFrenchShortDate(existing.submittedAt)} · '
                '${existing.wordCount} mots',
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveEdit,
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
