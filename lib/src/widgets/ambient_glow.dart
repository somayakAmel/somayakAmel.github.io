import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/core.dart';

/// A very soft blue-to-purple wash that drifts behind the hero
/// (design system §What makes this portfolio memorable).
///
/// ## The one indulgence
///
/// This is the single decorative flourish in the app, and it earns its place by
/// being nearly invisible: two large, heavily-blurred radial gradients at ~15%
/// alpha that drift on a 22-second cycle. If a visitor consciously notices it
/// animating, it is too strong.
///
/// Constraints it respects:
///  - **Decorative only.** Purple is used here precisely because this carries no
///    text and no meaning — it is the one place `accentSecondary` is allowed
///    (SPEC §14, and the AA analysis behind [ColorsManager.accentSecondary]).
///  - **Reduce-motion.** With the OS setting on, the gradients render at their
///    resting position and never animate (SPEC §13).
///  - **Cheap.** Animates only `Alignment` inside a `DecoratedBox` — no layout,
///    no repaint of children. `RepaintBoundary` keeps it off the content layer.
class AmbientGlow extends StatefulWidget {
  final Widget child;

  /// Overall strength. 1.0 is the hero; lower values suit smaller surfaces.
  final double intensity;

  const AmbientGlow({super.key, required this.child, this.intensity = 1.0});

  @override
  State<AmbientGlow> createState() => _AmbientGlowState();
}

class _AmbientGlowState extends State<AmbientGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Slow enough that the movement reads as ambient rather than as an
    // animation the eye wants to track.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Started here rather than in initState because it depends on MediaQuery.
    if (context.reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    // [RULE] A controller is disposed by whoever created it (guide §22.18).
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool still = context.reduceMotion;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                // Two orbits at different radii and phases, so the pair never
                // settles into an obvious repeating pattern.
                final double t = still ? 0.15 : _controller.value;
                final double a = t * 2 * math.pi;

                return Stack(
                  children: <Widget>[
                    // The blue blob sits behind the headline (start side,
                    // upper area) so the glow reads as light behind the
                    // content rather than an unrelated smudge beside it.
                    _blob(
                      color: colors.glowPrimary,
                      alignment: Alignment(
                        -0.75 + math.cos(a) * 0.18,
                        -0.55 + math.sin(a) * 0.14,
                      ),
                      radius: 0.9,
                    ),
                    // Purple trails to the end side at a different phase, so
                    // the pair never settles into an obvious pattern.
                    _blob(
                      color: colors.glowSecondary,
                      alignment: Alignment(
                        0.35 + math.cos(a + math.pi * 0.7) * 0.2,
                        -0.35 + math.sin(a + math.pi * 0.7) * 0.14,
                      ),
                      radius: 0.7,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }

  Widget _blob({
    required Color color,
    required Alignment alignment,
    required double radius,
  }) => Positioned.fill(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: alignment,
          radius: radius,
          colors: <Color>[
            color.withValues(
              alpha: (color.a * widget.intensity).clamp(0.0, 1.0),
            ),
            color.withValues(alpha: 0),
          ],
          // A short first stop keeps the core soft; the long tail is what makes
          // the edge unfindable, which is the difference between "ambient" and
          // "there is a circle on the page".
          stops: const <double>[0.0, 0.72],
        ),
      ),
    ),
  );
}
