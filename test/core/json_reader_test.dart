import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/json_reader.dart';
import 'package:portfolio/core/domain/entities/localized_text.dart';

/// The defensive-parsing guarantees every model depends on: a malformed content
/// file must degrade one card, never crash the app (PROJECT_SPEC §9).
void main() {
  group('JsonReader', () {
    test('str falls back instead of throwing on a missing key', () {
      expect(<String, dynamic>{}.str('missing'), '');
      expect(<String, dynamic>{}.str('missing', 'fallback'), 'fallback');
    });

    test('str coerces non-string values', () {
      expect(<String, dynamic>{'n': 42}.str('n'), '42');
    });

    test('strOrNull treats blank and the literal "null" as absent', () {
      expect(<String, dynamic>{'a': null}.strOrNull('a'), isNull);
      expect(<String, dynamic>{'a': '   '}.strOrNull('a'), isNull);
      expect(<String, dynamic>{'a': 'null'}.strOrNull('a'), isNull);
      expect(<String, dynamic>{'a': 'NULL'}.strOrNull('a'), isNull);
      expect(<String, dynamic>{'a': 'real'}.strOrNull('a'), 'real');
    });

    test('intOr parses strings and numbers, falling back otherwise', () {
      expect(<String, dynamic>{'v': 7}.intOr('v'), 7);
      expect(<String, dynamic>{'v': '7'}.intOr('v'), 7);
      expect(<String, dynamic>{'v': 7.9}.intOr('v'), 7);
      expect(<String, dynamic>{'v': 'abc'}.intOr('v', 3), 3);
      expect(<String, dynamic>{}.intOr('v', 3), 3);
    });

    test('boolOr accepts bool, 1/0, and "true"/"false"', () {
      expect(<String, dynamic>{'b': true}.boolOr('b'), isTrue);
      expect(<String, dynamic>{'b': 1}.boolOr('b'), isTrue);
      expect(<String, dynamic>{'b': '1'}.boolOr('b'), isTrue);
      expect(<String, dynamic>{'b': 'true'}.boolOr('b'), isTrue);
      expect(<String, dynamic>{'b': 0}.boolOr('b'), isFalse);
      expect(<String, dynamic>{}.boolOr('b'), isFalse);
    });

    test('objList and strList return empty on malformed input', () {
      expect(<String, dynamic>{'l': 'not a list'}.objList('l'), isEmpty);
      expect(<String, dynamic>{}.objList('l'), isEmpty);
      expect(<String, dynamic>{'l': 'not a list'}.strList('l'), isEmpty);
    });

    test('localized reads the canonical {en, ar} shape', () {
      final LocalizedText t = <String, dynamic>{
        'title': <String, dynamic>{'en': 'Hello', 'ar': 'مرحبا'},
      }.localized('title');
      expect(t.en, 'Hello');
      expect(t.ar, 'مرحبا');
    });

    test('localized accepts a bare string as both languages', () {
      // A half-finished content file should still render.
      final LocalizedText t = <String, dynamic>{'title': 'Flutter'}.localized(
        'title',
      );
      expect(t.en, 'Flutter');
      expect(t.ar, 'Flutter');
    });

    test('localized returns empty for a missing key', () {
      expect(<String, dynamic>{}.localized('nope').isEmpty, isTrue);
    });

    test('dateOrNull returns null for absent or unparseable dates', () {
      expect(<String, dynamic>{'d': '2024-03-01'}.dateOrNull('d'),
          DateTime(2024, 3));
      expect(<String, dynamic>{'d': null}.dateOrNull('d'), isNull);
      expect(<String, dynamic>{'d': 'garbage'}.dateOrNull('d'), isNull);
    });
  });

  group('enumFromValue', () {
    test('matches case-insensitively', () {
      expect(
        enumFromValue(_Fruit.values, 'BANANA', fallback: _Fruit.apple),
        _Fruit.banana,
      );
    });

    test('falls back on an unknown value rather than throwing', () {
      // A typo in a JSON file must degrade one card, not white-screen the app.
      expect(
        enumFromValue(_Fruit.values, 'durian', fallback: _Fruit.apple),
        _Fruit.apple,
      );
      expect(
        enumFromValue(_Fruit.values, null, fallback: _Fruit.apple),
        _Fruit.apple,
      );
    });
  });

  group('LocalizedText', () {
    test('resolve falls back to English when Arabic is empty', () {
      const LocalizedText t = LocalizedText(en: 'Hello', ar: '');
      expect(t.resolve('ar'), 'Hello');
    });

    test('resolve falls back to Arabic when English is empty', () {
      const LocalizedText t = LocalizedText(en: '', ar: 'مرحبا');
      expect(t.resolve('en'), 'مرحبا');
    });

    test('resolve picks the requested language when both are present', () {
      const LocalizedText t = LocalizedText(en: 'Hello', ar: 'مرحبا');
      expect(t.resolve('en'), 'Hello');
      expect(t.resolve('ar'), 'مرحبا');
    });
  });
}

enum _Fruit { apple, banana }
