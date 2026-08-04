import 'package:flutter/material.dart';

import '../../core/core.dart';

/// Clamps content width and centres it on large screens (PROJECT_SPEC §12).
///
/// Without this, a 2560px monitor stretches every row edge to edge and line
/// length blows past readability. Prose blocks pass [AppSize.maxProseWidth] to
/// hold measure near 70 characters (SPEC §15).
class MaxWidthWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const MaxWidthWrapper({super.key, required this.child, this.maxWidth});

  /// Deliberately exposes no `alignment`: this widget's one job is to centre a
  /// width-clamped column on the page. Alignment of content WITHIN that column
  /// belongs to the child's own crossAxisAlignment. Conflating the two produced
  /// a real bug — a start-aligned wrapper pinned the whole column to the screen
  /// edge on desktop instead of centring it.
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? AppSize.maxContentWidth,
      ),
      child: child,
    ),
  );
}

/// Clamps prose to a readable measure (~70 characters) WITHOUT ever exceeding
/// the available width.
///
/// A bare `ConstrainedBox(maxWidth: 720)` does nothing on a 390px phone, and
/// text inside a centre-aligned Column then lays out at its intrinsic width and
/// runs off the screen — a horizontal-overflow bug the spec forbids outright
/// (§12). Taking the minimum of the ideal measure and the real constraint fixes
/// it at every width.
class ProseWidth extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ProseWidth({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final double ideal = maxWidth ?? AppSize.maxProseWidth;
      final double available = constraints.maxWidth;
      final double limit = available.isFinite && available < ideal
          ? available
          : ideal;

      // SizedBox, not ConstrainedBox: a max-width constraint still lets a
      // greedy child (Text fills its constraints) expand to the parent's full
      // width. Fixing the width is what actually holds the measure.
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(width: limit, child: child),
      );
    },
  );
}
