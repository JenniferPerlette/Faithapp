import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/data/onboarding_repository.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/onboarding/screens/splash_screen.dart';

/// Racine de navigation : splash (toujours affiché brièvement au
/// démarrage), puis onboarding ou Accueil selon
/// [onboardingCompleteProvider].
class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  bool _splashElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _splashElapsed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashElapsed) return const SplashScreen();

    final onboardingComplete = ref.watch(onboardingCompleteProvider);
    return onboardingComplete ? const HomeShell() : const OnboardingFlow();
  }
}
