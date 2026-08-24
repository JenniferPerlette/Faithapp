import 'package:faithfocus/core/utils/lock_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isLockedAt', () {
    test('is locked before the unlock time', () {
      final now = DateTime(2026, 8, 6, 9, 30);
      expect(isLockedAt(now, 18 * 60), isTrue);
    });

    test('is unlocked exactly at and after the unlock time', () {
      final atUnlock = DateTime(2026, 8, 6, 18, 0);
      final afterUnlock = DateTime(2026, 8, 6, 23, 59);
      expect(isLockedAt(atUnlock, 18 * 60), isFalse);
      expect(isLockedAt(afterUnlock, 18 * 60), isFalse);
    });

    test('re-locks after midnight, before the next unlock time', () {
      final justAfterMidnight = DateTime(2026, 8, 7, 0, 5);
      expect(isLockedAt(justAfterMidnight, 18 * 60), isTrue);
    });
  });

  group('remainingUntilUnlock', () {
    test('computes the remaining duration until today\'s unlock time', () {
      final now = DateTime(2026, 8, 6, 14, 48);
      final remaining = remainingUntilUnlock(now, 18 * 60);
      expect(remaining, const Duration(hours: 3, minutes: 12));
    });
  });

  group('formatDurationHm', () {
    test('formats hours and minutes', () {
      expect(
        formatDurationHm(const Duration(hours: 3, minutes: 12)),
        '3 h 12',
      );
    });

    test('formats minutes only when under an hour', () {
      expect(formatDurationHm(const Duration(minutes: 8)), '8 min');
    });
  });
}
