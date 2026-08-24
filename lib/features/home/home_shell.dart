import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/profile_repository.dart';
import '../../core/platform/app_blocker_channel.dart';
import '../../core/utils/lock_schedule.dart';
import '../../core/utils/streak_calculator.dart';
import '../../core/utils/ticker.dart';
import '../blocking/screens/blocked_app_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../study/screens/study_tab_screen.dart';
import 'screens/home_locked_screen.dart';
import 'screens/home_unlocked_screen.dart';

/// Racine post-onboarding : barre de navigation à 3 onglets (Accueil /
/// Étude / Profil), reprise telle quelle du design.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    // "jours de suite" avance une fois par jour calendaire, à l'ouverture
    // de l'app — pas à chaque rebuild (le profil ne réémettra plus tant que
    // `lastActivityDate` reste "aujourd'hui").
    Future.microtask(_recordActivityIfNewDay);
  }

  Future<void> _recordActivityIfNewDay() async {
    final profileRepository = ref.read(profileRepositoryProvider);
    final profile = await profileRepository.watchProfile().first;
    final today = DateTime.now();
    final last = profile.lastActivityDate;
    final isSameDay =
        last != null &&
        last.year == today.year &&
        last.month == today.month &&
        last.day == today.day;
    if (isSameDay) return;

    final update = advanceStreakForToday(
      lastActivityDate: last,
      currentStreakDays: profile.currentStreakDays,
      longestStreakDays: profile.longestStreakDays,
      now: today,
    );
    await profileRepository.updateProfile(
      profile.copyWith(
        currentStreakDays: update.currentStreakDays,
        longestStreakDays: update.longestStreakDays,
        lastActivityDate: today,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileStreamProvider);
    final now = ref.watch(nowProvider).value ?? DateTime.now();

    ref.listen(blockedAppAttemptProvider, (previous, next) {
      final appId = next.value;
      if (appId == null) return;
      final profile = profileAsync.value;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlockedAppScreen(
            appName: appId,
            unlockTimeLabel: profile?.unlockTimeLabel ?? '--:--',
          ),
        ),
      );
    });

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Impossible de charger le profil : $error')),
      ),
      data: (profile) {
        final locked = isLockedAt(now, profile.unlockTimeMinutes);
        final pages = [
          locked
              ? HomeLockedScreen(profile: profile)
              : HomeUnlockedScreen(profile: profile),
          StudyTabScreen(locked: locked, profile: profile),
          const ProfileScreen(),
        ];

        return Scaffold(
          body: IndexedStack(index: _tabIndex, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tabIndex,
            onDestinationSelected: (index) =>
                setState(() => _tabIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Étude',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
