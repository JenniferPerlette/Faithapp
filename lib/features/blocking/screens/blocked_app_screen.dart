import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/data/daily_verses.dart';

/// "{App} est bloquée" : affiché quand
/// `AppBlockerChannel.onBlockedAppAttempt` signale une tentative d'ouverture
/// d'une application non autorisée pendant la période verrouillée. Pur
/// Flutter — aucune modification du natif (overlay Android/Shield iOS),
/// conformément au périmètre retenu pour cette passe.
class BlockedAppScreen extends StatelessWidget {
  const BlockedAppScreen({
    super.key,
    required this.appName,
    required this.unlockTimeLabel,
  });

  final String appName;
  final String unlockTimeLabel;

  Future<void> _openBible() async {
    final appUri = Uri.parse('youversion://');
    final webUri = Uri.parse('https://www.bible.com');
    final openedApp = await launchUrl(
      appUri,
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);
    if (!openedApp) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.veilleColors;
    final verse = dailyVerseFor(DateTime.now());

    return Scaffold(
      backgroundColor: colors.blockedBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(34, 90, 34, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 44, color: colors.mahogany),
              const SizedBox(height: 22),
              Text(
                '$appName est bloquée',
                textAlign: TextAlign.center,
                style: AppTheme.newsreader(
                  context,
                  fontSize: 24,
                  color: colors.blockedText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Reviens à $unlockTimeLabel — ou nourris ton âme en '
                'attendant.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: colors.blockedText, height: 1.5),
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      '« ${verse.text} »',
                      textAlign: TextAlign.center,
                      style: AppTheme.newsreader(context, fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      verse.reference,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openBible,
                  style: ElevatedButton.styleFrom(backgroundColor: colors.mahogany),
                  child: const Text('Ouvrir ma Bible'),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Ouvre ton app Bible installée, ou le Store si tu n'en as pas",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: colors.blockedText),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text('Retour à Veille', style: TextStyle(color: colors.blockedText)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
