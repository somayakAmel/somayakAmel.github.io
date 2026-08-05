import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/design_system/theme/app_color_scheme.dart';
import 'package:portfolio/core/managers/colors_manager.dart';

/// Locks the palette to WCAG AA (PROJECT_SPEC §14).
///
/// The spec commits to AA, so a colour tweak that quietly drops a text token
/// below 4.5:1 should fail the build rather than ship. This caught two real
/// problems during the design pass: the tertiary text token sat at 3.67:1 on
/// cards, and the secondary purple accent fails for text at 4.18:1 — the
/// latter is why purple is decorative-only.

/// Relative luminance, per WCAG 2.1.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  const AppColorScheme s = AppColorScheme.dark;

  /// The surfaces text is actually rendered on.
  const Map<String, Color> surfaces = <String, Color>{
    'surface0': ColorsManager.darkSurface0,
    'surface1': ColorsManager.darkSurface1,
    'surface2': ColorsManager.darkSurface2,
    'surface3': ColorsManager.darkSurface3,
  };

  group('text tokens meet AA (4.5:1)', () {
    const Map<String, Color> textTokens = <String, Color>{
      'textPrimary': ColorsManager.darkTextPrimary,
      'textSecondary': ColorsManager.darkTextSecondary,
      'textTertiary': ColorsManager.darkTextTertiary,
    };

    textTokens.forEach((String name, Color colour) {
      surfaces.forEach((String surfaceName, Color surface) {
        test('$name on $surfaceName', () {
          expect(
            _contrast(colour, surface),
            greaterThanOrEqualTo(4.5),
            reason:
                '$name on $surfaceName is '
                '${_contrast(colour, surface).toStringAsFixed(2)}:1',
          );
        });
      });
    });
  });

  group('accent meets AA as text and UI', () {
    surfaces.forEach((String surfaceName, Color surface) {
      test('accent on $surfaceName', () {
        expect(_contrast(s.accent, surface), greaterThanOrEqualTo(4.5));
      });
    });

    test('accentSecondaryText meets AA where purple text is used', () {
      surfaces.forEach((String _, Color surface) {
        expect(
          _contrast(s.accentSecondaryText, surface),
          greaterThanOrEqualTo(4.5),
        );
      });
    });
  });

  group('decorative purple', () {
    test('is documented as failing AA for text — hence decorative-only', () {
      // Not an aspiration: this asserts the CURRENT state, so if someone
      // lightens accentSecondary enough to pass, this test fails and prompts
      // them to relax the decorative-only rule deliberately.
      expect(
        _contrast(s.accentSecondary, ColorsManager.darkSurface2),
        lessThan(4.5),
      );
    });

    test('still clears the 3:1 floor for non-text graphics', () {
      expect(
        _contrast(s.accentSecondary, ColorsManager.darkSurface0),
        greaterThanOrEqualTo(3.0),
      );
    });
  });

  group('surface ladder', () {
    test('every step is lighter than the one below it', () {
      final List<Color> ladder = <Color>[
        ColorsManager.darkSurface0,
        ColorsManager.darkSurface1,
        ColorsManager.darkSurface2,
        ColorsManager.darkSurface3,
        ColorsManager.darkSurface4,
      ];
      for (int i = 1; i < ladder.length; i++) {
        expect(
          _luminance(ladder[i]),
          greaterThan(_luminance(ladder[i - 1])),
          reason: 'surface$i must be lighter than surface${i - 1}',
        );
      }
    });

    test('all surfaces share one hue family', () {
      // Mixing 240° neutrals with 220° blue steps reads as "slightly off"
      // without the viewer being able to name why.
      final List<double> hues = <Color>[
        ColorsManager.darkSurface0,
        ColorsManager.darkSurface1,
        ColorsManager.darkSurface2,
        ColorsManager.darkSurface3,
        ColorsManager.darkSurface4,
      ].map((Color c) => HSLColor.fromColor(c).hue).toList();

      final double first = hues.first;
      for (final double hue in hues) {
        expect(
          (hue - first).abs(),
          lessThanOrEqualTo(12),
          reason: 'surface hues drift: $hues',
        );
      }
    });
  });
}
