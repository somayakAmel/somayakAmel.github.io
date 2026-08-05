import 'package:flutter/material.dart';

/// Font family selection (ARCHITECTURE_GUIDE §14.2), extended to a
/// two-role system.
///
/// ## Why two Latin families
///
/// A portfolio has two jobs that want different type. Headlines should read as
/// technical and deliberate; body copy should disappear so a recruiter can skim
/// it. One family cannot be optimal at both:
///
///  - **Space Grotesk** (display) — geometric with unusual details. Distinctive
///    at 40-56pt, tiring at 15pt.
///  - **Inter** (body) — designed for UI text: tall x-height, open apertures,
///    unambiguous 1/l/I. Neutral by intent, which is what body copy wants.
///
/// Arabic uses **IBM Plex Sans Arabic** for both roles: pairing two Arabic
/// families would be a decision with no payoff, and Plex Arabic reads well from
/// caption sizes up to display.
class FontConstants {
  const FontConstants._();

  static const String displayLatin = 'SpaceGrotesk';
  static const String bodyLatin = 'Inter';
  static const String arabicFamily = 'IBMPlexSansArabic';

  static bool _isArabic = false;

  /// True when the active locale is Arabic — both roles collapse to the Arabic
  /// family.
  static bool get isArabic => _isArabic;

  /// Headline family for the active language.
  static String get displayFamily => _isArabic ? arabicFamily : displayLatin;

  /// Body family for the active language.
  static String get bodyFamily => _isArabic ? arabicFamily : bodyLatin;

  /// The default family Flutter falls back to (Scaffold text, dialogs).
  static String get fontFamily => bodyFamily;

  /// Called by LocaleCubit whenever the language changes (guide §12.4).
  static void changeFontFamily({required bool isArabic}) {
    _isArabic = isArabic;
  }
}

/// [RULE] Four weights maximum (design system §Typography).
class FontWeightManager {
  const FontWeightManager._();

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

/// The type ladder. Two values per role: desktop and mobile.
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
  static const double f72 = 72;

  // Semantic roles — desktop
  static const double displayDesktop = f72;
  static const double h1Desktop = f40;
  static const double h2Desktop = f24;
  static const double h3Desktop = f20;
  static const double bodyLargeDesktop = f18;
  static const double bodyDesktop = f16;
  static const double captionDesktop = f14;
  static const double labelDesktop = f13;

  // Semantic roles — mobile
  static const double displayMobile = f40;
  static const double h1Mobile = f28;
  static const double h2Mobile = f20;
  static const double h3Mobile = f18;
  static const double bodyLargeMobile = f16;
  static const double bodyMobile = f15;
  static const double captionMobile = f13;
  static const double labelMobile = f12;
}

/// Line height ratios: tight for display, 1.2 headings, 1.5 body.
class LineHeights {
  const LineHeights._();

  static const double display = 1.05;
  static const double heading = 1.2;
  static const double body = 1.5;
  static const double tight = 1.1;
}

/// Letter spacing. Large display type needs negative tracking to avoid looking
/// loose; small uppercase labels need positive tracking to stay legible.
class LetterSpacings {
  const LetterSpacings._();

  static const double display = -1.5;
  static const double heading = -0.5;
  static const double body = 0;
  static const double label = 1.2;
}

/// [RULE] Typography is composed at the call site from a [FontStyles] role +
/// [FontSize] + [FontWeightManager]. There is no TextTheme with named styles
/// (guide §14.2).
class FontStyles {
  const FontStyles._();

  /// Headlines, hero type, section titles, numbers that act as display.
  static TextStyle display() => TextStyle(
    fontFamily: FontConstants.displayFamily,
    fontWeight: FontWeightManager.bold,
  );

  /// Everything else.
  static TextStyle body() => TextStyle(
    fontFamily: FontConstants.bodyFamily,
    fontWeight: FontWeightManager.regular,
  );
}
