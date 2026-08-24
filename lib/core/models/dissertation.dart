import 'package:flutter/foundation.dart';

/// Une "dissertation" : la courte réflexion écrite que l'utilisateur doit
/// soumettre pour terminer une étude thématique et retrouver l'accès libre
/// à l'appareil (écran "Écran verrouillé" du design).
@immutable
class Dissertation {
  final String id;
  final String themeId;
  final String themeTitle;
  final String content;
  final DateTime submittedAt;
  final DateTime updatedAt;

  const Dissertation({
    required this.id,
    required this.themeId,
    required this.themeTitle,
    required this.content,
    required this.submittedAt,
    required this.updatedAt,
  });

  int get wordCount {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  Dissertation copyWith({
    String? id,
    String? themeId,
    String? themeTitle,
    String? content,
    DateTime? submittedAt,
    DateTime? updatedAt,
  }) {
    return Dissertation(
      id: id ?? this.id,
      themeId: themeId ?? this.themeId,
      themeTitle: themeTitle ?? this.themeTitle,
      content: content ?? this.content,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeId': themeId,
      'themeTitle': themeTitle,
      'content': content,
      'submittedAt': submittedAt,
      'updatedAt': updatedAt,
    };
  }

  /// `map['submittedAt']`/`map['updatedAt']` doivent déjà être des
  /// [DateTime] : conversion à charge du dépôt appelant (Timestamp Firestore
  /// vs DateTime natif Hive), comme pour [UserProfile].
  factory Dissertation.fromMap(String id, Map<String, dynamic> map) {
    return Dissertation(
      id: id,
      themeId: map['themeId'] as String? ?? '',
      themeTitle: map['themeTitle'] as String? ?? '',
      content: map['content'] as String? ?? '',
      submittedAt: map['submittedAt'] as DateTime? ?? DateTime.now(),
      updatedAt: map['updatedAt'] as DateTime? ?? DateTime.now(),
    );
  }
}
