import 'package:flutter/material.dart';

import '../../managers/colors_manager.dart';

/// The role-alias tier of the colour system (ARCHITECTURE_GUIDE §14.1, tier 3).
///
/// ## Why this exists instead of flat statics
///
/// The guide reads colours as `ColorsManager.primaryButtonBackground` — flat
/// `static const` access. That cannot support a second theme without editing
/// every widget, and light mode is a stated v2 requirement. So role aliases move
/// onto an immutable scheme object resolved from the theme, and widgets read
/// `context.colors.textPrimary`.
///
/// This is deviation 1 of 3 in PROJECT_SPEC §19. Token naming, tiering, and the
/// manager-class structure are otherwise unchanged from the guide.
///
/// [RULE] Widgets read role aliases from here. They never reference
/// `ColorsManager` raw palette entries directly.
@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  // Surfaces — elevation by lightness, not shadow
  final Color surface0;
  final Color surface1;
  final Color surface2;
  final Color surface3;
  final Color surface4;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  // Borders
  final Color borderSubtle;
  final Color borderStrong;

  // Accent — exactly one
  final Color accent;
  final Color accentHover;
  final Color accentMuted;
  final Color onAccent;

  // Semantic
  final Color success;
  final Color warning;
  final Color danger;

  final Brightness brightness;

  const AppColorScheme({
    required this.surface0,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.surface4,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.borderSubtle,
    required this.borderStrong,
    required this.accent,
    required this.accentHover,
    required this.accentMuted,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.brightness,
  });

  /// The v1 scheme.
  static const AppColorScheme dark = AppColorScheme(
    surface0: ColorsManager.darkSurface0,
    surface1: ColorsManager.darkSurface1,
    surface2: ColorsManager.darkSurface2,
    surface3: ColorsManager.darkSurface3,
    surface4: ColorsManager.darkSurface4,
    textPrimary: ColorsManager.darkTextPrimary,
    textSecondary: ColorsManager.darkTextSecondary,
    textTertiary: ColorsManager.darkTextTertiary,
    textDisabled: ColorsManager.darkTextDisabled,
    borderSubtle: ColorsManager.darkBorderSubtle,
    borderStrong: ColorsManager.darkBorderStrong,
    accent: ColorsManager.accent,
    accentHover: ColorsManager.accentHover,
    accentMuted: ColorsManager.accentMuted,
    onAccent: ColorsManager.darkSurface0,
    success: ColorsManager.success,
    warning: ColorsManager.warning,
    danger: ColorsManager.danger,
    brightness: Brightness.dark,
  );

  /// Defined now so v2 is a token swap plus a ThemeCubit — no widget changes.
  /// Not referenced anywhere in v1.
  static const AppColorScheme light = AppColorScheme(
    surface0: ColorsManager.lightSurface0,
    surface1: ColorsManager.lightSurface1,
    surface2: ColorsManager.lightSurface2,
    surface3: ColorsManager.lightSurface3,
    surface4: ColorsManager.lightSurface4,
    textPrimary: ColorsManager.lightTextPrimary,
    textSecondary: ColorsManager.lightTextSecondary,
    textTertiary: ColorsManager.lightTextTertiary,
    textDisabled: ColorsManager.lightTextDisabled,
    borderSubtle: ColorsManager.lightBorderSubtle,
    borderStrong: ColorsManager.lightBorderStrong,
    accent: ColorsManager.accent,
    accentHover: ColorsManager.accentHover,
    accentMuted: ColorsManager.accentMuted,
    onAccent: ColorsManager.pureWhite,
    success: ColorsManager.success,
    warning: ColorsManager.warning,
    danger: ColorsManager.danger,
    brightness: Brightness.light,
  );

  @override
  AppColorScheme copyWith({
    Color? surface0,
    Color? surface1,
    Color? surface2,
    Color? surface3,
    Color? surface4,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? borderSubtle,
    Color? borderStrong,
    Color? accent,
    Color? accentHover,
    Color? accentMuted,
    Color? onAccent,
    Color? success,
    Color? warning,
    Color? danger,
    Brightness? brightness,
  }) => AppColorScheme(
    surface0: surface0 ?? this.surface0,
    surface1: surface1 ?? this.surface1,
    surface2: surface2 ?? this.surface2,
    surface3: surface3 ?? this.surface3,
    surface4: surface4 ?? this.surface4,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    textDisabled: textDisabled ?? this.textDisabled,
    borderSubtle: borderSubtle ?? this.borderSubtle,
    borderStrong: borderStrong ?? this.borderStrong,
    accent: accent ?? this.accent,
    accentHover: accentHover ?? this.accentHover,
    accentMuted: accentMuted ?? this.accentMuted,
    onAccent: onAccent ?? this.onAccent,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    brightness: brightness ?? this.brightness,
  );

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      surface0: Color.lerp(surface0, other.surface0, t)!,
      surface1: Color.lerp(surface1, other.surface1, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      surface4: Color.lerp(surface4, other.surface4, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }
}

/// The accessor every widget uses: `context.colors.textPrimary`.
extension AppColorSchemeContext on BuildContext {
  AppColorScheme get colors =>
      Theme.of(this).extension<AppColorScheme>() ?? AppColorScheme.dark;
}
