import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../managers/fonts_manager.dart';
import '../../managers/values_manager.dart';
import 'app_color_scheme.dart';

/// Builds [ThemeData] from an [AppColorScheme].
///
/// The theme object stays deliberately minimal, as in ARCHITECTURE_GUIDE §10:
/// styling lives in the design-system widgets and the token managers, not in a
/// sprawling `ThemeData`. What lives here is only what Flutter's own widgets
/// (Scaffold, AppBar, selection handles, focus) need in order to match.
///
/// Adding light mode in v2 is: uncomment [light], add a ThemeCubit, add a
/// toggle. No widget changes (PROJECT_SPEC §15).
class ThemeManager {
  const ThemeManager._();

  static ThemeData get dark => _build(AppColorScheme.dark);

  /// v2. Ready, unused.
  static ThemeData get light => _build(AppColorScheme.light);

  static ThemeData _build(AppColorScheme scheme) {
    final bool isDark = scheme.brightness == Brightness.dark;

    return ThemeData(
      // Material 3. The guide pinned useMaterial3: false because its design
      // system assumed M2 metrics; this project builds its Custom* widgets
      // against M3 from the start, so there is no legacy to preserve.
      useMaterial3: true,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scheme.surface0,
      canvasColor: scheme.surface0,
      fontFamily: FontConstants.bodyFamily,

      // The single source of role aliases. Read via `context.colors`.
      extensions: <ThemeExtension<dynamic>>[scheme],

      colorScheme: ColorScheme(
        brightness: scheme.brightness,
        primary: scheme.accent,
        onPrimary: scheme.onAccent,
        secondary: scheme.accent,
        onSecondary: scheme.onAccent,
        error: scheme.danger,
        onError: scheme.onAccent,
        surface: scheme.surface0,
        onSurface: scheme.textPrimary,
        surfaceContainerHighest: scheme.surface3,
        outline: scheme.borderStrong,
        outlineVariant: scheme.borderSubtle,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: scheme.textPrimary),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      iconTheme: IconThemeData(color: scheme.textSecondary),

      dividerTheme: DividerThemeData(
        color: scheme.borderSubtle,
        thickness: AppSize.s1,
        space: AppSize.s1,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.surface4,
          borderRadius: BorderRadius.circular(BorderValues.small),
        ),
        textStyle: TextStyle(
          color: scheme.textPrimary,
          fontSize: FontSize.labelDesktop,
          fontFamily: FontConstants.bodyFamily,
        ),
      ),

      // Focus indicator — Flutter Web's default is inadequate, and every
      // interactive element needs a visible one (SPEC §14).
      focusColor: scheme.accent.withValues(alpha: 0.4),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.accent,
        selectionColor: scheme.accent.withValues(alpha: 0.3),
        selectionHandleColor: scheme.accent,
      ),

      // Web/desktop scrollbars: visible but unobtrusive.
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll<Color>(
          scheme.textTertiary.withValues(alpha: 0.5),
        ),
        radius: const Radius.circular(BorderValues.bFull),
        thickness: const WidgetStatePropertyAll<double>(AppSize.s6),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          // Cupertino slide on iOS, per the guide §9.3.
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          // Fade elsewhere — a slide on Web fights browser back (SPEC §13).
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
