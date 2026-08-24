import 'package:faithfocus/core/utils/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('advanceStreakForToday', () {
    test('starts at 1 when there is no prior activity', () {
      final update = advanceStreakForToday(
        lastActivityDate: null,
        currentStreakDays: 0,
        longestStreakDays: 0,
        now: DateTime(2026, 8, 6),
      );
      expect(update.currentStreakDays, 1);
      expect(update.longestStreakDays, 1);
    });

    test('stays the same when activity already recorded today', () {
      final update = advanceStreakForToday(
        lastActivityDate: DateTime(2026, 8, 6, 8),
        currentStreakDays: 5,
        longestStreakDays: 5,
        now: DateTime(2026, 8, 6, 20),
      );
      expect(update.currentStreakDays, 5);
      expect(update.longestStreakDays, 5);
    });

    test('increments by one on the following calendar day', () {
      final update = advanceStreakForToday(
        lastActivityDate: DateTime(2026, 8, 5),
        currentStreakDays: 5,
        longestStreakDays: 7,
        now: DateTime(2026, 8, 6),
      );
      expect(update.currentStreakDays, 6);
      expect(update.longestStreakDays, 7);
    });

    test('raises the longest streak once the current streak beats it', () {
      final update = advanceStreakForToday(
        lastActivityDate: DateTime(2026, 8, 5),
        currentStreakDays: 7,
        longestStreakDays: 7,
        now: DateTime(2026, 8, 6),
      );
      expect(update.currentStreakDays, 8);
      expect(update.longestStreakDays, 8);
    });

    test('resets to 1 when more than a day was missed', () {
      final update = advanceStreakForToday(
        lastActivityDate: DateTime(2026, 8, 1),
        currentStreakDays: 12,
        longestStreakDays: 20,
        now: DateTime(2026, 8, 6),
      );
      expect(update.currentStreakDays, 1);
      expect(update.longestStreakDays, 20);
    });
  });
}
