import '../domain/entities/localized_text.dart';

/// Defensive JSON accessors (ARCHITECTURE_GUIDE §6.3).
///
/// [RULE] A malformed content file must degrade one card, never crash the app
/// (PROJECT_SPEC §9). Every model's `fromJson` reads through these helpers
/// rather than indexing the map directly.
extension JsonReader on Map<String, dynamic> {
  /// A required string, defaulting to empty rather than throwing.
  String str(String key, [String fallback = '']) {
    final Object? value = this[key];
    if (value == null) return fallback;
    return value.toString();
  }

  /// An optional string. Blank and the literal string "null" both read as null,
  /// since hand-edited JSON produces both.
  String? strOrNull(String key) {
    final Object? value = this[key];
    if (value == null) return null;
    final String s = value.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  int intOr(String key, [int fallback = 0]) {
    final Object? value = this[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  bool boolOr(String key, [bool fallback = false]) {
    final Object? value = this[key];
    if (value is bool) return value;
    // Backends and hand-edited files both produce 1/0 and "true"/"false".
    if (value is num) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return fallback;
  }

  /// A nested object, or an empty map when absent — so callers can chain
  /// without null checks.
  Map<String, dynamic> obj(String key) {
    final Object? value = this[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  /// A list of objects, or empty when absent or malformed.
  List<Map<String, dynamic>> objList(String key) {
    final Object? value = this[key];
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false);
  }

  /// A list of strings, or empty when absent or malformed.
  List<String> strList(String key) {
    final Object? value = this[key];
    if (value is! List) return const [];
    return value
        .where((Object? e) => e != null)
        .map((Object? e) => e.toString())
        .toList(growable: false);
  }

  /// A bilingual content string.
  ///
  /// Accepts the canonical `{"en": "...", "ar": "..."}` shape, and also a bare
  /// string — which is treated as the same value in both languages, so a
  /// half-finished content file still renders.
  LocalizedText localized(String key) {
    final Object? value = this[key];
    if (value == null) return const LocalizedText.empty();
    if (value is String) return LocalizedText.same(value);
    if (value is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(value);
      return LocalizedText(en: map.str('en'), ar: map.str('ar'));
    }
    return const LocalizedText.empty();
  }

  /// A list of bilingual strings.
  List<LocalizedText> localizedList(String key) {
    final Object? value = this[key];
    if (value is! List) return const [];
    return value
        .map((Object? e) {
          if (e is String) return LocalizedText.same(e);
          if (e is Map) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(e);
            return LocalizedText(en: map.str('en'), ar: map.str('ar'));
          }
          return const LocalizedText.empty();
        })
        .where((LocalizedText t) => t.isNotEmpty)
        .toList(growable: false);
  }

  /// An ISO-8601 date, or null. `null` means "present" / "no expiry" (SPEC §9).
  DateTime? dateOrNull(String key) {
    final String? raw = strOrNull(key);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// A required date, falling back to the epoch so a malformed date sorts last
  /// rather than throwing.
  DateTime date(String key) => dateOrNull(key) ?? DateTime(1970);
}

/// Parses an enum from its JSON string value.
///
/// [RULE] Every enum parsed from JSON has an explicit fallback. An unrecognised
/// value must never throw — a typo should degrade one card, not white-screen
/// the app (SPEC §8.4).
T enumFromValue<T extends Enum>(
  List<T> values,
  String? raw, {
  required T fallback,
}) {
  if (raw == null) return fallback;
  final String needle = raw.trim().toLowerCase();
  for (final T value in values) {
    if (value.name.toLowerCase() == needle) return value;
  }
  return fallback;
}
