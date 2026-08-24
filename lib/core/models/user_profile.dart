import 'package:flutter/foundation.dart';

/// Profil utilisateur Veille : réglages (heure de déblocage, applications
/// autorisées, notifications, mode sombre) et statistiques affichées sur
/// l'écran Profil (streak, études terminées, temps rendu à Dieu).
///
/// Il n'y a pas d'écran de connexion dans le design : ce document existe dès
/// la fin de l'onboarding, propriété de l'utilisateur authentifié de façon
/// anonyme (cf. [AuthService]).
@immutable
class UserProfile {
  final String displayName;

  /// Heure de déblocage quotidienne, en minutes depuis minuit (ex: 18:00 =
  /// 1080). Simple à comparer/persister, formatée à l'affichage.
  final int unlockTimeMinutes;

  /// Identifiants (cf. `AllowedAppsCatalog`) des applications autorisées en
  /// plus de la Bible, toujours implicite et non désactivable. Borné à
  /// [kMaxAllowedApps].
  final List<String> allowedAppIds;

  final bool notificationsEnabled;
  final bool darkModeEnabled;

  final int currentStreakDays;
  final int longestStreakDays;
  final int studiesCompleted;

  /// "Temps rendu à Dieu" : cumul du temps passé en période verrouillée,
  /// en minutes.
  final int hoursReturnedMinutes;

  /// Dernier jour où l'app a été ouverte — sert uniquement à faire avancer
  /// [currentStreakDays]/[longestStreakDays] (cf. `advanceStreakForToday`),
  /// jamais affiché tel quel.
  final DateTime? lastActivityDate;

  final DateTime createdAt;

  const UserProfile({
    required this.displayName,
    required this.unlockTimeMinutes,
    required this.allowedAppIds,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.studiesCompleted,
    required this.hoursReturnedMinutes,
    this.lastActivityDate,
    required this.createdAt,
  });

  static const int kMaxAllowedApps = 3;

  /// Profil "vierge" utilisé juste après l'onboarding, avant toute étude.
  factory UserProfile.initial({
    required String displayName,
    required int unlockTimeMinutes,
    required List<String> allowedAppIds,
  }) {
    return UserProfile(
      displayName: displayName,
      unlockTimeMinutes: unlockTimeMinutes,
      allowedAppIds: allowedAppIds,
      notificationsEnabled: true,
      darkModeEnabled: false,
      currentStreakDays: 0,
      longestStreakDays: 0,
      studiesCompleted: 0,
      hoursReturnedMinutes: 0,
      createdAt: DateTime.now(),
    );
  }

  /// Profil de démonstration repris du design ("Léa M.", 24 jours de suite,
  /// 6 études, 18h), utilisé pour seeder le dépôt local au premier lancement
  /// afin que l'app soit démontrable même sans Firestore configuré.
  factory UserProfile.seedDemo() {
    return UserProfile(
      displayName: 'Léa M.',
      unlockTimeMinutes: 18 * 60,
      allowedAppIds: const ['phone', 'notes'],
      notificationsEnabled: true,
      darkModeEnabled: false,
      currentStreakDays: 24,
      longestStreakDays: 24,
      studiesCompleted: 6,
      hoursReturnedMinutes: 18 * 60,
      lastActivityDate: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(days: 24)),
    );
  }

  String get unlockTimeLabel => formatMinutesAsHm(unlockTimeMinutes);

  String get hoursReturnedLabel {
    final hours = hoursReturnedMinutes ~/ 60;
    return '${hours}h';
  }

  UserProfile copyWith({
    String? displayName,
    int? unlockTimeMinutes,
    List<String>? allowedAppIds,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    int? currentStreakDays,
    int? longestStreakDays,
    int? studiesCompleted,
    int? hoursReturnedMinutes,
    DateTime? lastActivityDate,
    DateTime? createdAt,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      unlockTimeMinutes: unlockTimeMinutes ?? this.unlockTimeMinutes,
      allowedAppIds: allowedAppIds ?? this.allowedAppIds,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      studiesCompleted: studiesCompleted ?? this.studiesCompleted,
      hoursReturnedMinutes: hoursReturnedMinutes ?? this.hoursReturnedMinutes,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'unlockTimeMinutes': unlockTimeMinutes,
      'allowedAppIds': allowedAppIds,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'currentStreakDays': currentStreakDays,
      'longestStreakDays': longestStreakDays,
      'studiesCompleted': studiesCompleted,
      'hoursReturnedMinutes': hoursReturnedMinutes,
      'lastActivityDate': lastActivityDate,
      'createdAt': createdAt,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      displayName: map['displayName'] as String? ?? 'Ami(e)',
      unlockTimeMinutes: (map['unlockTimeMinutes'] as num?)?.toInt() ?? 18 * 60,
      allowedAppIds: List<String>.from(
        (map['allowedAppIds'] as List?) ?? const [],
      ),
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: map['darkModeEnabled'] as bool? ?? false,
      currentStreakDays: (map['currentStreakDays'] as num?)?.toInt() ?? 0,
      longestStreakDays: (map['longestStreakDays'] as num?)?.toInt() ?? 0,
      studiesCompleted: (map['studiesCompleted'] as num?)?.toInt() ?? 0,
      hoursReturnedMinutes:
          (map['hoursReturnedMinutes'] as num?)?.toInt() ?? 0,
      // Ces deux champs doivent déjà être des DateTime : c'est la
      // responsabilité de chaque dépôt de convertir son format natif
      // (Timestamp Firestore, DateTime déjà natif pour Hive) avant d'appeler
      // ce constructeur.
      lastActivityDate: map['lastActivityDate'] as DateTime?,
      createdAt: map['createdAt'] as DateTime? ?? DateTime.now(),
    );
  }
}

/// Formate un nombre de minutes depuis minuit en "HH:mm" (ex: 1080 -> "18:00").
String formatMinutesAsHm(int minutesSinceMidnight) {
  final normalized = minutesSinceMidnight % (24 * 60);
  final hours = normalized ~/ 60;
  final minutes = normalized % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(hours)}:${two(minutes)}';
}
