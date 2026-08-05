import 'package:flutter/material.dart';

import 'colors_manager.dart';

/// Sizing ladder.
///
/// [RULE] Naming encodes the value (ARCHITECTURE_GUIDE §14.3):
/// `s24` = size 24. Decimals use an underscore: `s1_5` = 1.5, `s_5` = 0.5.
///
/// [RULE] All spacing comes from the 8px scale (4 permitted for tight pairs):
/// 4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 · 96 (SPEC §15).
class AppSize {
  const AppSize._();

  static const double zero = 0;
  static const double s_5 = .5;
  static const double s1 = 1;
  static const double s1_5 = 1.5;
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s56 = 56;
  static const double s64 = 64;
  static const double s80 = 80;
  static const double s96 = 96;
  static const double s120 = 120;
  static const double s160 = 160;
  static const double s200 = 200;
  static const double s240 = 240;
  static const double s320 = 320;
  static const double s400 = 400;
  static const double s480 = 480;
  static const double s600 = 600;

  /// Content is clamped to this width and centred on large screens (SPEC §12).
  static const double maxContentWidth = 1200;

  /// Prose blocks clamp tighter, to hold line length near 70 characters.
  static const double maxProseWidth = 720;
}

/// Padding ladder. Same numeric values as [AppSize]; a separate class because
/// the guide keeps padding semantically distinct at call sites.
class PaddingValues {
  const PaddingValues._();

  static const EdgeInsetsDirectional zero = EdgeInsetsDirectional.zero;

  static const double p2 = 2;
  static const double p4 = 4;
  static const double p6 = 6;
  static const double p8 = 8;
  static const double p10 = 10;
  static const double p12 = 12;
  static const double p16 = 16;
  static const double p20 = 20;
  static const double p24 = 24;
  static const double p32 = 32;
  static const double p40 = 40;
  static const double p48 = 48;
  static const double p64 = 64;
  static const double p96 = 96;

  // Semantic aliases
  static const double screenPaddingMobile = p20;
  static const double screenPaddingDesktop = p32;

  /// Vertical rhythm between Home sections, owned by SectionContainer.
  static const double sectionGapMobile = p64;
  static const double sectionGapDesktop = p96;
}

/// Border radius ladder.
///
/// [RULE] Three sizes, no random radii (design system §Corners):
///   small 12 · medium 18 · large 24.
///
/// Anything below 12 is reserved for genuinely tiny elements (a 2px progress
/// segment), and [bFull] is the pill.
class BorderValues {
  const BorderValues._();

  static const BorderRadiusDirectional zero = BorderRadiusDirectional.zero;

  /// Chips, progress segments, and other sub-12 elements only.
  static const double b4 = 4;
  static const double b8 = 8;

  /// The scale.
  static const double small = 12;
  static const double medium = 18;
  static const double large = 24;

  /// Pill.
  static const double bFull = 1000;

  // Legacy aliases, mapped onto the three-step scale so no call site keeps a
  // radius that is off-system.
  static const double b12 = small;
  static const double b16 = medium;
  static const double b20 = medium;
  static const double b24 = large;
  static const double b6 = b8;
  static const double b10 = small;
}

/// Duration ladder, in milliseconds unless the name says otherwise.
///
/// [RULE] `dm300` = duration 300ms, `ds2` = duration 2 seconds (§14.3).
/// Every animation in the app uses one of these four (SPEC §13).
class DurationValues {
  const DurationValues._();

  /// Hover, tap feedback, colour transitions.
  static const double dm150 = 150;

  /// Card lift, chip states.
  static const double dm250 = 250;

  /// Section entrance, page transitions, scroll-to-anchor.
  static const double dm400 = 400;

  /// Hero stagger total, counter count-up.
  static const double dm600 = 600;

  /// Stagger interval between siblings in a section.
  static const double staggerStep = 80;

  /// Hard ceiling on the splash preload (SPEC risk R-9).
  static const double splashTimeout = 1200;
}

/// Animation curves. No springs, no bounce, no elastic — they read as playful,
/// and the brief asks for premium and minimal (SPEC §13).
class AppCurves {
  const AppCurves._();

  /// Entrances.
  static const Curve entrance = Curves.easeOutCubic;

  /// Reversible states — hover, toggles.
  static const Curve state = Curves.easeInOut;

  /// Exits.
  static const Curve exit = Curves.easeOut;
}

/// Centralised shadows — adopted from ARCHITECTURE_GUIDE §22.15, which flags
/// inline shadow declaration as a defect in the original.
///
/// Note: on dark surfaces, shadows are nearly invisible. Elevation is carried
/// by surface lightness (SPEC §15); these are reserved for genuinely floating
/// elements — hover-lifted cards and the scrolled app bar.
class AppShadow {
  const AppShadow._();

  static List<BoxShadow> get small => [
    BoxShadow(
      color: ColorsManager.pureBlack.withValues(alpha: 0.20),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: ColorsManager.pureBlack.withValues(alpha: 0.28),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get hovered => [
    BoxShadow(
      color: ColorsManager.pureBlack.withValues(alpha: 0.36),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
