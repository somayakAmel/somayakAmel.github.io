import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';

/// Runtime-JSON localization for UI chrome (ARCHITECTURE_GUIDE §12).
///
/// Translations load from `lang/<code>.json` at runtime — not `.arb`, not
/// generated. Content strings are a separate mechanism ([LocalizedText]).
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = <String, String>{};

  Future<void> load() async {
    final String jsonString = await rootBundle.loadString(
      'lang/${locale.languageCode}.json',
    );
    final Map<String, dynamic> jsonMap =
        json.decode(jsonString) as Map<String, dynamic>;
    _localizedStrings = jsonMap.map<String, String>(
      (String key, dynamic value) => MapEntry<String, String>(
        key,
        value.toString(),
      ),
    );
  }

  String? translate(String key) => _localizedStrings[key];

  bool get isEnLocale => locale.languageCode == 'en';

  bool get isArLocale => locale.languageCode == 'ar';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizationsSetup.supportedLanguageCodes.contains(
        locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Wiring handed to `MaterialApp` (ARCHITECTURE_GUIDE §12.3).
class AppLocalizationsSetup {
  const AppLocalizationsSetup._();

  static const List<String> supportedLanguageCodes = <String>['en', 'ar'];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  /// Falls back to the first supported locale when the device asks for one we
  /// do not carry.
  static Locale? localeResolutionCallback(
    Locale? deviceLocale,
    Iterable<Locale> supported,
  ) {
    if (deviceLocale == null) return supported.first;
    for (final Locale locale in supported) {
      if (locale.languageCode == deviceLocale.languageCode) return locale;
    }
    return supported.first;
  }
}

/// The access pattern (ARCHITECTURE_GUIDE §12.2).
///
/// [RULE] Always `StringsManager.someKey.tr(context)`.
///
/// [RULE] A missing key shows a loud error in debug and falls back silently to
/// the key itself in release — surfacing gaps during development without ever
/// showing an error to a user.
extension LocaleExtension on String {
  String tr(BuildContext context) {
    final String? translated = AppLocalizations.of(context)?.translate(this);
    if (translated != null) return translated;
    return kReleaseMode ? this : '⚠ missing: $this';
  }
}
