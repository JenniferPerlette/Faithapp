import 'package:faithfocus/core/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile', () {
    test('round-trips through toMap/fromMap', () {
      final original = UserProfile(
        displayName: 'Léa M.',
        unlockTimeMinutes: 18 * 60,
        allowedAppIds: const ['phone', 'notes'],
        notificationsEnabled: true,
        darkModeEnabled: true,
        currentStreakDays: 24,
        longestStreakDays: 30,
        studiesCompleted: 6,
        hoursReturnedMinutes: 18 * 60,
        lastActivityDate: DateTime(2026, 8, 6),
        createdAt: DateTime(2026, 7, 13),
      );

      final restored = UserProfile.fromMap(original.toMap());

      expect(restored.displayName, original.displayName);
      expect(restored.unlockTimeMinutes, original.unlockTimeMinutes);
      expect(restored.allowedAppIds, original.allowedAppIds);
      expect(restored.notificationsEnabled, original.notificationsEnabled);
      expect(restored.darkModeEnabled, original.darkModeEnabled);
      expect(restored.currentStreakDays, original.currentStreakDays);
      expect(restored.longestStreakDays, original.longestStreakDays);
      expect(restored.studiesCompleted, original.studiesCompleted);
      expect(restored.hoursReturnedMinutes, original.hoursReturnedMinutes);
      expect(restored.lastActivityDate, original.lastActivityDate);
      expect(restored.createdAt, original.createdAt);
    });

    test('unlockTimeLabel formats HH:mm', () {
      final profile = UserProfile.initial(
        displayName: 'Ami(e)',
        unlockTimeMinutes: 9 * 60 + 5,
        allowedAppIds: const [],
      );
      expect(profile.unlockTimeLabel, '09:05');
    });

    test('hoursReturnedLabel formats whole hours', () {
      final profile = UserProfile.initial(
        displayName: 'Ami(e)',
        unlockTimeMinutes: 0,
        allowedAppIds: const [],
      ).copyWith(hoursReturnedMinutes: 18 * 60);
      expect(profile.hoursReturnedLabel, '18h');
    });

    test('allowed apps are capped at kMaxAllowedApps by convention', () {
      expect(UserProfile.kMaxAllowedApps, 3);
    });
  });
}
