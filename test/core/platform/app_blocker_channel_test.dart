import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faithfocus/core/platform/app_blocker_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('validateFocusSessionArgs', () {
    test('accepts a valid whitelist and duration', () {
      expect(
        () => validateFocusSessionArgs(
          whitelistedPackageIds: const ['com.faithfocus', 'com.youversion'],
          timerDuration: const Duration(minutes: 30),
        ),
        returnsNormally,
      );
    });

    test('rejects a whitelist larger than kMaxWhitelistSize', () {
      final oversized = List.generate(
        kMaxWhitelistSize + 1,
        (i) => 'com.app.$i',
      );

      expect(
        () => validateFocusSessionArgs(whitelistedPackageIds: oversized),
        throwsArgumentError,
      );
    });

    test('rejects a whitelist containing an empty/blank string', () {
      expect(
        () => validateFocusSessionArgs(
          whitelistedPackageIds: const ['com.faithfocus', '   '],
        ),
        throwsArgumentError,
      );
    });

    test('rejects a zero or negative timerDuration', () {
      expect(
        () => validateFocusSessionArgs(
          whitelistedPackageIds: const ['com.faithfocus'],
          timerDuration: Duration.zero,
        ),
        throwsArgumentError,
      );
      expect(
        () => validateFocusSessionArgs(
          whitelistedPackageIds: const ['com.faithfocus'],
          timerDuration: const Duration(seconds: -1),
        ),
        throwsArgumentError,
      );
    });

    test('rejects a timerDuration exceeding kMaxTimerDuration', () {
      expect(
        () => validateFocusSessionArgs(
          whitelistedPackageIds: const ['com.faithfocus'],
          timerDuration: kMaxTimerDuration + const Duration(minutes: 1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('FakeAppBlockerChannel', () {
    test('requestPermissions returns the configured value', () async {
      final fake = FakeAppBlockerChannel()..permissionsGranted = false;

      expect(await fake.requestPermissions(), isFalse);
    });

    test('startFocusSession validates its arguments', () async {
      final fake = FakeAppBlockerChannel();

      await expectLater(
        fake.startFocusSession(
          whitelistedPackageIds: const [''],
        ),
        throwsArgumentError,
      );
    });

    test('onBlockedAppAttempt emits simulated events', () async {
      final fake = FakeAppBlockerChannel();

      final future = fake.onBlockedAppAttempt.first;
      fake.simulateBlockedAppAttempt('com.instagram.android');

      expect(await future, 'com.instagram.android');
      fake.dispose();
    });
  });

  group('MethodChannelAppBlockerChannel', () {
    const methodChannel = MethodChannel('com.faithfocus/blocker');
    const eventChannel = EventChannel('com.faithfocus/blocker_events');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() {
      messenger.setMockMethodCallHandler(methodChannel, null);
      messenger.setMockStreamHandler(eventChannel, null);
    });

    test('requestPermissions forwards the native result', () async {
      messenger.setMockMethodCallHandler(methodChannel, (call) async {
        expect(call.method, 'requestPermissions');
        return true;
      });

      final channel = MethodChannelAppBlockerChannel(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      );

      expect(await channel.requestPermissions(), isTrue);
    });

    test('startFocusSession sends validated, serialized arguments', () async {
      MethodCall? received;
      messenger.setMockMethodCallHandler(methodChannel, (call) async {
        received = call;
        return null;
      });

      final channel = MethodChannelAppBlockerChannel(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      );

      final scheduledStart = DateTime.utc(2026, 1, 1, 6);
      final scheduledEnd = DateTime.utc(2026, 1, 1, 7);

      await channel.startFocusSession(
        whitelistedPackageIds: const ['com.faithfocus'],
        scheduledStart: scheduledStart,
        scheduledEnd: scheduledEnd,
        timerDuration: const Duration(minutes: 10),
      );

      expect(received!.method, 'startFocusSession');
      expect(received!.arguments, {
        'whitelistedPackageIds': ['com.faithfocus'],
        'scheduledStart': scheduledStart.toIso8601String(),
        'scheduledEnd': scheduledEnd.toIso8601String(),
        'timerDurationSeconds': 600,
      });
    });

    test('startFocusSession rejects invalid input before invoking native', () async {
      var invoked = false;
      messenger.setMockMethodCallHandler(methodChannel, (call) async {
        invoked = true;
        return null;
      });

      final channel = MethodChannelAppBlockerChannel(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      );

      await expectLater(
        channel.startFocusSession(
          whitelistedPackageIds: const [],
          timerDuration: const Duration(seconds: -5),
        ),
        throwsArgumentError,
      );
      expect(invoked, isFalse);
    });

    test('stopFocusSession invokes the native method', () async {
      String? invokedMethod;
      messenger.setMockMethodCallHandler(methodChannel, (call) async {
        invokedMethod = call.method;
        return null;
      });

      final channel = MethodChannelAppBlockerChannel(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      );

      await channel.stopFocusSession();

      expect(invokedMethod, 'stopFocusSession');
    });

    test('onBlockedAppAttempt streams native events as strings', () async {
      messenger.setMockStreamHandler(
        eventChannel,
        MockStreamHandler.inline(
          onListen: (arguments, events) {
            events.success('com.tiktok.android');
            events.endOfStream();
          },
        ),
      );

      final channel = MethodChannelAppBlockerChannel(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      );

      final events = await channel.onBlockedAppAttempt.toList();

      expect(events, ['com.tiktok.android']);
    });
  });
}
