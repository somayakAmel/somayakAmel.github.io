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
  // Dark surface ladder — "depth, not dark mode".
  //
  // Elevation is carried by surface LIGHTNESS, not shadow: on a near-black
  // page a drop shadow is invisible, so each layer is simply lighter than the
  // one beneath it.
  //
  // [RULE] Every surface sits in ONE hue family (240°) at low saturation.
  // An earlier draft mixed 240° neutrals with 220° blue-tinted steps and
  // swung saturation 6% -> 39% -> 6% -> 28% down the ladder; that reads as
  // "slightly off" on screen without the viewer being able to name why.
  // Keeping hue fixed and moving only lightness is what makes the ladder feel
  // deliberate.
  // ---------------------------------------------------------------------------
  static const Color darkSurface0 = Color(0xFF09090B); // page — almost black
  static const Color darkSurface1 = Color(0xFF0F0F13); // alternating section
  static const Color darkSurface2 = Color(0xFF18181B); // card
  static const Color darkSurface3 = Color(0xFF222229); // raised / hovered card
  static const Color darkSurface4 = Color(0xFF2C2C35); // overlay, tooltip

  // ---------------------------------------------------------------------------
  // Dark text ladder — all contrast-verified against surfaces 0-2.
  // Deliberately not pure white: reduces halation for astigmatic readers and
  // reads as more premium (SPEC §14, §15).
  // ---------------------------------------------------------------------------
  static const Color darkTextPrimary = Color(0xFFF4F4F5); // 18.1:1 on surface0
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // 7.8:1
  // Lightened from the zinc-500 (#71717A) this ladder started from: that
  // measured 3.67:1 on cards, under the 4.5:1 AA needs for body text, and it
  // carries real content (timeline dates, credential ids, footer copyright).
  // #8E8E99 clears AA on every surface in the ladder.
  static const Color darkTextTertiary = Color(0xFF8E8E99); // 6.1:1 / 4.9:1
  static const Color darkTextDisabled = Color(0xFF5C5C66);

  static const Color darkBorderSubtle = Color(0x14FFFFFF); // 8% white
  static const Color darkBorderStrong = Color(0x29FFFFFF); // 16% white

  // ---------------------------------------------------------------------------
  // Light ladder — defined now so v2 is a token swap, not a refactor.
  // Not referenced by any widget in v1.
  // ---------------------------------------------------------------------------
  static const Color lightSurface0 = Color(0xFFFAFAFA);
  static const Color lightSurface1 = Color(0xFFF4F4F5);
  static const Color lightSurface2 = Color(0xFFFFFFFF);
  static const Color lightSurface3 = Color(0xFFEDEDF0);
  static const Color lightSurface4 = Color(0xFFE4E4E7);

  static const Color lightTextPrimary = Color(0xFF18181B);
  static const Color lightTextSecondary = Color(0xFF52525B);
  static const Color lightTextTertiary = Color(0xFF71717A);
  static const Color lightTextDisabled = Color(0xFFA1A1AA);

  static const Color lightBorderSubtle = Color(0x14000000);
  static const Color lightBorderStrong = Color(0x29000000);

  // ---------------------------------------------------------------------------
  // Accents
  // ---------------------------------------------------------------------------

  /// The primary accent. CTAs, links, active states, focus rings, the
  /// "present" timeline marker.
  ///
  /// Verified AA: 6.59:1 on surface0, 5.86:1 on surface2, 4.69:1 on surface3.
  static const Color accent = Color(0xFF6C8EFF);
  static const Color accentHover = Color(0xFF8AA5FF);
  static const Color accentMuted = Color(0x1F6C8EFF); // 12% — chip backgrounds

  /// The secondary accent.
  ///
  /// [RULE] DECORATIVE ONLY — the ambient hero glow, gradient edges, and other
  /// non-text graphics. It must never carry text or a meaning-bearing icon,
  /// because it measures 4.18:1 on cards and 3.35:1 on elevated surfaces,
  /// under the 4.5:1 that WCAG AA requires for body text (SPEC §14).
  ///
  /// Use [accentSecondaryText] where a purple TEXT treatment is genuinely
  /// wanted.
  static const Color accentSecondary = Color(0xFF8B5CF6);

  /// AA-passing purple, for the rare case where purple text is needed.
  /// 7.0:1 on surface0, 6.2:1 on surface2.
  static const Color accentSecondaryText = Color(0xFFC4B5FD);

  /// Ambient glow. Very soft, and only ever behind interactive or hero
  /// elements — never as a page-wide wash.
  static const Color glowPrimary = Color(0x266C8EFF); // ~15% blue
  static const Color glowSecondary = Color(0x268B5CF6); // ~15% purple

  // ---------------------------------------------------------------------------
  // Semantic — reserved for status indicators only.
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF3DD68C);
  static const Color warning = Color(0xFFF5C451);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color info = accent;
}
