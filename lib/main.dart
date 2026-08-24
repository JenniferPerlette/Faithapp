import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_root.dart';
import 'core/data/dissertation_repository.dart';
import 'core/data/onboarding_repository.dart';
import 'core/data/profile_repository.dart';
import 'core/platform/app_blocker_channel.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final profileBox = await Hive.openBox('profile_box');
  final dissertationsBox = await Hive.openBox('dissertations_box');
  final appMetaBox = await Hive.openBox('app_meta_box');

  // Ce dépôt n'a ni `firebase_options.dart`, ni `google-services.json` /
  // `GoogleService-Info.plist` sur cette machine : aucun projet Firebase
  // réel n'est encore rattaché à l'app (`flutterfire configure` reste à
  // faire séparément). `Firebase.initializeApp()` échoue donc ici sans
  // configuration native — on bascule alors sur les dépôts locaux (Hive)
  // plutôt que de planter au démarrage.
  String? uid;
  try {
    await Firebase.initializeApp();
    uid = await AuthService(FirebaseAuth.instance).signInAnonymously();
  } catch (_) {
    uid = null;
  }

  final profileRepository = uid != null
      ? FirestoreProfileRepository(uid: uid)
      : LocalProfileRepository(profileBox);
  final dissertationRepository = uid != null
      ? FirestoreDissertationRepository(uid: uid)
      : LocalDissertationRepository(dissertationsBox);
  final onboardingRepository = OnboardingRepository(appMetaBox);

  runApp(
    ProviderScope(
      overrides: [
        // Implémentation réelle en production ; les tests widget la
        // surchargent par FakeAppBlockerChannel.
        appBlockerChannelProvider.overrideWithValue(
          MethodChannelAppBlockerChannel(),
        ),
        profileRepositoryProvider.overrideWithValue(profileRepository),
        dissertationRepositoryProvider.overrideWithValue(
          dissertationRepository,
        ),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
        onboardingCompleteProvider.overrideWith(
          () => OnboardingCompleteNotifier(onboardingRepository.isComplete),
        ),
      ],
      child: const VeilleApp(),
    ),
  );
}

class VeilleApp extends ConsumerWidget {
  const VeilleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeEnabled =
        ref.watch(profileStreamProvider).value?.darkModeEnabled ?? false;

    return MaterialApp(
      title: 'Veille',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: const AppRoot(),
    );
  }
}
