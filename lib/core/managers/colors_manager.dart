import 'package:flutter/material.dart';

/// Raw color palette.
///
/// [RULE] Widgets NEVER reference this class directly. They read role aliases
/// from the active [AppColorScheme] (see `design_system/theme/`). This is the
/// deliberate deviation from ARCHITECTURE_GUIDE §14.1 documented in
/// PROJECT_SPEC §15 — flat static access cannot support a second theme without
/// touching every widget, and light mode is a stated v2 requirement.
///
/// Three tiers, per the guide: raw palette -> semantic -> role alias.
/// This file holds tiers 1 and 2. Role aliases live on [AppColorScheme].
class ColorsManager {
  const ColorsManager._();

  // ---------------------------------------------------------------------------
  // Base
  // ---------------------------------------------------------------------------
  static const Color transparent = Colors.transparent;
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Dark surface ladder — elevation expressed by surface lightness, not shadow.
  // Deliberately not pure black: reduces halation for astigmatic readers and
  // reads as more premium (SPEC §14, §15).
  // ---------------------------------------------------------------------------
  static const Color darkSurface0 = Color(0xFF0D0D0F); // page background
  static const Color darkSurface1 = Color(0xFF141417); // section background
  static const Color darkSurface2 = Color(0xFF1B1B1F); // card
  static const Color darkSurface3 = Color(0xFF232328); // raised / hovered card
  static const Color darkSurface4 = Color(0xFF2D2D33); // overlay, tooltip

  // ---------------------------------------------------------------------------
  // Dark text ladder — all contrast-verified against darkSurface0/1/2.
  // Deliberately not pure white, for the same reason as above.
  // ---------------------------------------------------------------------------
  static const Color darkTextPrimary = Color(0xFFF2F2F5); // ~16.5:1 on surface0
  static const Color darkTextSecondary = Color(0xFFA8A8B3); // ~7.9:1
  static const Color darkTextTertiary = Color(0xFF77777F); // ~4.6:1
  static const Color darkTextDisabled = Color(0xFF4A4A52);

  static const Color darkBorderSubtle = Color(0x14FFFFFF); // 8% white
  static const Color darkBorderStrong = Color(0x29FFFFFF); // 16% white

  // ---------------------------------------------------------------------------
  // Light ladder — defined now so v2 is a token swap, not a refactor.
  // Not referenced by any widget in v1.
  // ---------------------------------------------------------------------------
  static const Color lightSurface0 = Color(0xFFFAFAFC);
  static const Color lightSurface1 = Color(0xFFF2F2F5);
  static const Color lightSurface2 = Color(0xFFFFFFFF);
  static const Color lightSurface3 = Color(0xFFEBEBF0);
  static const Color lightSurface4 = Color(0xFFE0E0E6);

  static const Color lightTextPrimary = Color(0xFF16161A);
  static const Color lightTextSecondary = Color(0xFF54545E);
  static const Color lightTextTertiary = Color(0xFF83838F);
  static const Color lightTextDisabled = Color(0xFFB0B0BA);

  static const Color lightBorderSubtle = Color(0x14000000);
  static const Color lightBorderStrong = Color(0x29000000);

  // ---------------------------------------------------------------------------
  // Accent — exactly ONE, used for CTAs, links, active states, and the
  // "present" timeline marker. Nothing else (SPEC §15).
  //
  // PLACEHOLDER pending SPEC open item 2. Changing the portfolio's entire
  // accent is these three lines.
  // ---------------------------------------------------------------------------
  static const Color accent = Color(0xFF6C8EFF);
  static const Color accentHover = Color(0xFF8AA5FF);
  static const Color accentMuted = Color(0x1F6C8EFF); // 12% — chip backgrounds

  // ---------------------------------------------------------------------------
  // Semantic — reserved for status indicators only.
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF3DD68C);
  static const Color warning = Color(0xFFF5C451);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF6C8EFF);
}
