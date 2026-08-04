import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/core.dart';
import 'max_width_wrapper.dart';

/// The wrapper every Home section sits in — vertical rhythm, screen padding,
/// width clamp, and the one-shot entrance animation (PROJECT_SPEC §10.2).
///
/// This is the single place the page's spacing is retuned.
///
/// ## The one-shot rule
///
/// [RULE] Entrance animations fire ONCE per session, never on scroll-back.
/// Re-animating every time a section re-enters the viewport is the fastest way
/// to make a page feel cheap and fights the reader (SPEC §13, risk R-5).
///
/// [RULE] Honors `MediaQuery.disableAnimations` — with reduce-motion on, the
/// content appears instantly at full opacity (SPEC §13, §14).
class SectionContainer extends StatefulWidget {
  final Widget child;

  /// Stable key for the visibility detector. Must be unique per section.
  final String sectionId;

  /// Anchor target for the app bar's scroll-to-section nav.
  final GlobalKey? anchorKey;

  final Color? background;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  /// Set false for full-bleed sections (the Hero) that manage their own
  /// horizontal padding.
  final bool constrained;

  const SectionContainer({
    super.key,
    required this.child,
    required this.sectionId,
    this.anchorKey,
    this.background,
    this.padding,
    this.maxWidth,
    this.constrained = true,
  });

  @override
  State<SectionContainer> createState() => _SectionContainerState();
}

class _SectionContainerState extends State<SectionContainer> {
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    // VisibilityDetector only reports a CHANGE in visibility. A section that is
    // already on screen at first paint therefore never gets a callback, and
    // would stay at opacity 0 forever — the whole page renders blank until the
    // visitor happens to scroll.
    //
    // So visibility is seeded one frame after mount: anything already in the
    // viewport animates in immediately, and everything below the fold still
    // waits for the detector. Caught by screenshotting the running app; no unit
    // test would have surfaced it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasAnimated) return;
      final RenderObject? box = context.findRenderObject();
      if (box is! RenderBox || !box.hasSize) return;

      final double screenHeight = MediaQuery.sizeOf(context).height;
      final double top = box.localToGlobal(Offset.zero).dy;

      if (top < screenHeight) {
        setState(() => _hasAnimated = true);
      }
    });
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // Fires once, at 20% visible, then never again for this session.
    if (_hasAnimated || info.visibleFraction < 0.2) return;
    if (!mounted) return;
    setState(() => _hasAnimated = true);
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = context.reduceMotion;
    final bool shown = _hasAnimated || reduceMotion;

    final double verticalGap = context.responsive(
      mobile: PaddingValues.sectionGapMobile,
      desktop: PaddingValues.sectionGapDesktop,
    );

    final double horizontalGap = context.responsive(
      mobile: PaddingValues.screenPaddingMobile,
      desktop: PaddingValues.screenPaddingDesktop,
    );

    Widget content = widget.child;

    if (widget.constrained) {
      content = MaxWidthWrapper(maxWidth: widget.maxWidth, child: content);
    }

    content = content.withPadding(
      widget.padding ?? (verticalGap, horizontalGap).pSymmetricVH,
    );

    if (!reduceMotion) {
      content = AnimatedSlide(
        offset: shown ? Offset.zero : const Offset(0, 0.04),
        duration: DurationValues.dm400.milliseconds,
        curve: AppCurves.entrance,
        child: AnimatedOpacity(
          opacity: shown ? 1 : 0,
          duration: DurationValues.dm400.milliseconds,
          curve: AppCurves.entrance,
          child: content,
        ),
      );
    }

    return VisibilityDetector(
      key: Key('section-${widget.sectionId}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Container(
        key: widget.anchorKey,
        width: double.infinity,
        color: widget.background,
        child: content,
      ),
    );
  }
}
