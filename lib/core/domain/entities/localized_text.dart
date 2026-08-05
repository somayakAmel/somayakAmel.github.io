import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// A content string carried in both supported languages.
///
/// ## Why a value object rather than `titleEn` / `titleAr` field pairs
///
/// Resolution happens in exactly one place, the type makes it impossible to
/// forget a translation, and a third language is one field plus one branch
/// (PROJECT_SPEC §8.2).
///
/// ## Scope
///
/// This handles portfolio *content* — project titles, bios, achievements —
/// which lives in `assets/data/*.json`. UI *chrome* (button labels, section
/// headers, errors) uses `StringsManager` + `.tr(context)` against `lang/*.json`.
/// Two mechanisms, deliberately: different owners, different edit cadence.
/// Do not unify them.
@immutable
class LocalizedText extends Equatable {
  final String en;
  final String ar;

  const LocalizedText({required this.en, required this.ar});

  const LocalizedText.empty() : en = '', ar = '';

  /// Both languages carry the same value — for content that is not translated,
  /// such as a proper noun.
  const LocalizedText.same(String value) : en = value, ar = value;

  /// Resolves against a language code.
  ///
  /// [RULE] Falls back to English when the Arabic value is empty, so partial
  /// translation degrades rather than rendering a blank (SPEC risk R-10).
  /// `tool/validate_data.dart` reports every empty `ar` as a warning.
  String resolve(String languageCode) {
    if (languageCode == 'ar') return ar.trim().isNotEmpty ? ar : en;
    return en.trim().isNotEmpty ? en : ar;
  }

  /// Convenience for widgets, which almost always have a context to hand.
  String of(BuildContext context) =>
      resolve(Localizations.localeOf(context).languageCode);

  bool get isEmpty => en.trim().isEmpty && ar.trim().isEmpty;

  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [en, ar];

  @override
  String toString() => 'LocalizedText(en: $en, ar: $ar)';
}
