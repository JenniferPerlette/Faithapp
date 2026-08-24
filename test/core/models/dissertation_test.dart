import 'package:faithfocus/core/models/dissertation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dissertation', () {
    test('round-trips through toMap/fromMap', () {
      final original = Dissertation(
        id: 'patience-1',
        themeId: 'patience',
        themeTitle: 'La patience',
        content: 'Un texte de réflexion sur la patience.',
        submittedAt: DateTime(2026, 8, 3),
        updatedAt: DateTime(2026, 8, 3),
      );

      final restored = Dissertation.fromMap(original.id, original.toMap());

      expect(restored.id, original.id);
      expect(restored.themeId, original.themeId);
      expect(restored.themeTitle, original.themeTitle);
      expect(restored.content, original.content);
      expect(restored.submittedAt, original.submittedAt);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('wordCount counts whitespace-separated words', () {
      final dissertation = Dissertation(
        id: 'x',
        themeId: 'x',
        themeTitle: 'x',
        content: '  Un   texte  avec des espaces multiples  ',
        submittedAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      expect(dissertation.wordCount, 6);
    });

    test('wordCount is zero for empty content', () {
      final dissertation = Dissertation(
        id: 'x',
        themeId: 'x',
        themeTitle: 'x',
        content: '   ',
        submittedAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      expect(dissertation.wordCount, 0);
    });
  });
}
