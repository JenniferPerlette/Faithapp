import 'dart:io';

import 'package:faithfocus/app_root.dart';
import 'package:faithfocus/core/data/onboarding_repository.dart';
import 'package:faithfocus/core/data/profile_repository.dart';
import 'package:faithfocus/core/data/dissertation_repository.dart';
import 'package:faithfocus/core/models/user_profile.dart';
import 'package:faithfocus/core/platform/app_blocker_channel.dart';
import 'package:faithfocus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'test_doubles.dart';

void main() {
  late Directory tempDir;
  late Box onboardingBox;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('veille_test_hive');
    Hive.init(tempDir.path);
    onboardingBox = await Hive.openBox('onboarding_test_box');
  });

  tearDownAll(() async {
    await onboardingBox.close();
    await tempDir.delete(recursive: true);
  });

  Widget buildApp({required bool onboardingComplete}) {
    return ProviderScope(
      overrides: [
        appBlockerChannelProvider.overrideWithValue(FakeAppBlockerChannel()),
        profileRepositoryProvider.overrideWithValue(
          FakeProfileRepository(UserProfile.seedDemo()),
        ),
        dissertationRepositoryProvider.overrideWithValue(
          FakeDissertationRepository(),
        ),
        onboardingRepositoryProvider.overrideWithValue(
          OnboardingRepository(onboardingBox),
        ),
        onboardingCompleteProvider.overrideWith(
          () => OnboardingCompleteNotifier(onboardingComplete),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const AppRoot(),
      ),
    );
  }

  testWidgets('shows the welcome step once the splash clears, when '
      'onboarding is not complete', (tester) async {
    await tester.pumpWidget(buildApp(onboardingComplete: false));

    expect(find.text('Chargement de Veille…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 950));
    await tester.pump();

    expect(find.text('Veille'), findsWidgets);
    expect(
      find.text('Reste sur le droit chemin,\nune heure à la fois.'),
      findsOneWidget,
    );
  });

  testWidgets('goes straight to the Accueil tab bar when onboarding is '
      'already complete', (tester) async {
    await tester.pumpWidget(buildApp(onboardingComplete: true));

    await tester.pump(const Duration(milliseconds: 950));
    await tester.pump();

    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Étude'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
