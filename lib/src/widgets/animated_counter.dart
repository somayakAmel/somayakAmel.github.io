import 'package:flutter/material.dart';

import '../../core/core.dart';

/// Counts a numeric value up from zero, once (PROJECT_SPEC §10.2, §13).
///
/// Handles values like "5+", "20+", "3" by animating only the leading digits
/// and preserving any suffix. Non-numeric values render as-is.
///
/// [RULE] Honors reduce-motion: jumps straight to the final value (SPEC §13).
class AnimatedCounter extends StatelessWidget {
  final String value;
  final double? fontSize;
  final Color? color;

  const AnimatedCounter(
    this.value, {
    super.key,
    this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final RegExpMatch? match = RegExp(r'^(\d+)(.*)$').firstMatch(value.trim());

    // Not a number ("Present", "N/A") — nothing to count.
    if (match == null || context.reduceMotion) {
      return _text(context, value);
    }

    final int target = int.parse(match.group(1)!);
    final String suffix = match.group(2) ?? '';

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: target),
      duration: DurationValues.dm600.milliseconds,
      curve: AppCurves.entrance,
      builder: (BuildContext context, int current, _) =>
          // Semantics carries the FINAL value, not the tweening one: a screen
          // reader must never announce "1 Years Experience" because it happened
          // to read the tree mid-animation.
          Semantics(
            label: '$target$suffix',
            child: ExcludeSemantics(child: _text(context, '$current$suffix')),
          ),
    );
  }

  Widget _text(BuildContext context, String display) => CustomText.display(
    display,
    fontSize: fontSize ?? FontSize.h1Desktop,
    fontWeight: FontWeightManager.bold,
    color: color ?? context.colors.accent,
    height: LineHeights.tight,
  );
}
