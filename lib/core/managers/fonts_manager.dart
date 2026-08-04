import 'package:flutter/material.dart';

/// Font family selection, swapped by language (ARCHITECTURE_GUIDE §14.2).
///
/// [RULE] Exactly two families: one Latin, one Arabic (SPEC §15).
///
/// PLACEHOLDER pending SPEC open item 1. `null` means "use the platform
/// default", which keeps the app running until the families are confirmed and
/// the .ttf files land in assets/fonts/. Swapping to real fonts is these two
/// constants plus the pubspec `fonts:` block.
class FontConstants {
  const FontConstants._();

  static const String? englishFontFamily = null; // -> 'Inter'
  static const String? arabicFontFamily = null; // -> 'IBM Plex Sans Arabic'

  static String? _fontFamily = englishFontFamily;
  static String? get fontFamily => _fontFamily;

  static void changeFontFamily({required bool isArabic}) {
    _fontFamily = isArabic ? arabicFontFamily : englishFontFamily;
  }
}

/// [RULE] Four weights maximum (SPEC §15).
class FontWeightManager {
  const FontWeightManager._();

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

/// The type ladder from SPEC §15. Two values per role: desktop and mobile.
///
/// [RULE] Typography is composed at the call site from [FontStyles] +
/// [FontSize] + [FontWeightManager]. There is no TextTheme with named styles
/// (ARCHITECTURE_GUIDE §14.2).
class FontSize {
  const FontSize._();

  // Raw ladder
  static const double f12 = 12;
  static const double f13 = 13;
  static const double f14 = 14;
  static const double f15 = 15;
  static const double f16 = 16;
  static const double f18 = 18;
  static const double f20 = 20;
  static const double f24 = 24;
  static const double f28 = 28;
  static const double f34 = 34;
  static const double f40 = 40;
  static const double f56 = 56;

  // Semantic roles — desktop
  static const double displayDesktop = f56;
  static const double h1Desktop = f40;
  static const double h2Desktop = f24;
  static const double h3Desktop = f20;
  static const double bodyLargeDesktop = f18;
  static const double bodyDesktop = f16;
  static const double captionDesktop = f14;
  static const double labelDesktop = f13;

  // Semantic roles — mobile
  static const double displayMobile = f34;
  static const double h1Mobile = f28;
  static const double h2Mobile = f20;
  static const double h3Mobile = f18;
  static const double bodyLargeMobile = f16;
  static const double bodyMobile = f15;
  static const double captionMobile = f13;
  static const double labelMobile = f12;
}

/// Line height ratios (SPEC §15): 1.5 for body, 1.2 for headings.
class LineHeights {
  const LineHeights._();

  static const double heading = 1.2;
  static const double body = 1.5;
  static const double tight = 1.1;
}

class FontStyles {
  const FontStyles._();

  static TextStyle getRegularStyle() => TextStyle(
    fontFamily: FontConstants.fontFamily,
    fontWeight: FontWeightManager.regular,
  );

  static TextStyle getMediumStyle() => TextStyle(
    fontFamily: FontConstants.fontFamily,
    fontWeight: FontWeightManager.medium,
  );

  static TextStyle getSemiBoldStyle() => TextStyle(
    fontFamily: FontConstants.fontFamily,
    fontWeight: FontWeightManager.semiBold,
  );

  static TextStyle getBoldStyle() => TextStyle(
    fontFamily: FontConstants.fontFamily,
    fontWeight: FontWeightManager.bold,
  );
}
