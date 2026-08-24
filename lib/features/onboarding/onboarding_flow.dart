import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/onboarding_repository.dart';
import '../../core/data/profile_repository.dart';
import '../../core/models/user_profile.dart';
import 'screens/choose_allies_screen.dart';
import 'screens/ready_screen.dart';
import 'screens/welcome_screen.dart';

/// Les 3 étapes swipables de l'onboarding (après le splash) : bienvenue,
/// choix des applications, heure de déblocage. À la fin, écrit le profil
/// initial et marque l'onboarding comme terminé sur cet appareil.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();
  List<String> _selectedAppIds = const [];
  int _unlockTimeMinutes = 18 * 60;
  bool _saving = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);

    final profile = UserProfile.initial(
      displayName: 'Ami(e)',
      unlockTimeMinutes: _unlockTimeMinutes,
      allowedAppIds: _selectedAppIds,
    );
    await ref.read(profileRepositoryProvider).updateProfile(profile);
    await ref.read(onboardingRepositoryProvider).markComplete();
    ref.read(onboardingCompleteProvider.notifier).markComplete();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        WelcomeScreen(onNext: () => _goToPage(1)),
        ChooseAlliesScreen(
          selectedIds: _selectedAppIds,
          onChanged: (ids) => setState(() => _selectedAppIds = ids),
          onNext: () => _goToPage(2),
        ),
        ReadyScreen(
          unlockTimeMinutes: _unlockTimeMinutes,
          onUnlockTimeChanged: (minutes) =>
              setState(() => _unlockTimeMinutes = minutes),
          onFinish: _finish,
        ),
      ],
    );
  }
}
