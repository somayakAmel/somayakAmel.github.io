import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../managers/fonts_manager.dart';
import 'app_localizations.dart';

/// App-wide language state (ARCHITECTURE_GUIDE §12.3).
///
/// The state IS the [Locale], as in the guide's `locale_package`.
///
/// ## Registration
///
/// [RULE] Cubits are `registerFactory` — EXCEPT this one, which is a lazy
/// singleton because app-wide language must be a single shared instance
/// (guide §4.3, the documented exception).
///
/// ## Persistence
///
/// This is the ONE key SharedPreferences holds. It is not used as a database
/// (PROJECT_SPEC §19).
class LocaleCubit extends Cubit<Locale> {
  final SharedPreferences _prefs;

  LocaleCubit(this._prefs) : super(const Locale(_defaultLanguageCode));

  static const String _cacheKey = 'app_locale';
  static const String _defaultLanguageCode = 'en';

  static LocaleCubit get(BuildContext context) => BlocProvider.of(context);

  /// Restores the saved language, falling back to the device locale when the
  /// visitor has never chosen one.
  Future<void> getSavedLang() async {
    final String? saved = _prefs.getString(_cacheKey);

    if (saved != null &&
        AppLocalizationsSetup.supportedLanguageCodes.contains(saved)) {
      _apply(saved);
      return;
    }

    // No stored preference: honour the device, which is what an Arabic-speaking
    // visitor arriving from a link expects (PROJECT_SPEC J5).
    final String deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _apply(
      AppLocalizationsSetup.supportedLanguageCodes.contains(deviceCode)
          ? deviceCode
          : _defaultLanguageCode,
    );
  }

  Future<void> changeLang(String languageCode) async {
    if (!AppLocalizationsSetup.supportedLanguageCodes.contains(languageCode)) {
      return;
    }
    await _prefs.setString(_cacheKey, languageCode);
    _apply(languageCode);
  }

  /// Flips between the two supported languages — what the app-bar toggle calls.
  Future<void> toggleLang() =>
      changeLang(state.languageCode == 'ar' ? 'en' : 'ar');

  bool get isArabic => state.languageCode == 'ar';

  void _apply(String languageCode) {
    // Fonts swap with the language (guide §12.4). Harmless while both families
    // are null placeholders; correct the moment real fonts are declared.
    FontConstants.changeFontFamily(isArabic: languageCode == 'ar');
    emit(Locale(languageCode));
  }
}
