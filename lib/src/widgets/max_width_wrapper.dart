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
