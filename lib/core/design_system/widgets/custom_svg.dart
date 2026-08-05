import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../extensions/responsive_extension.dart';

/// SVG asset rendering (ARCHITECTURE_GUIDE §11.4).
///
/// [RULE] Icons and logos are SVG, rendered here. Raster images go through
/// `CustomImage` (§13.3).
///
/// Uses `colorFilter` rather than the deprecated `SvgPicture.color`, per the
/// guide's own §22.19 — the deprecated API is not carried forward.
class CustomSvg extends StatelessWidget {
  final String path;
  final double? size;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit fit;
  final Widget? fallback;
  final String? semanticLabel;

  const CustomSvg(
    this.path, {
    super.key,
    this.size,
    this.height,
    this.width,
    this.color,
    this.fit = BoxFit.contain,
    this.fallback,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      height: (height ?? size)?.rs,
      width: (width ?? size)?.rs,
      fit: fit,
      // Tint only when a colour is explicitly given — a brand logo must keep
      // its own colours (guide §13.3).
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
      placeholderBuilder: fallback == null ? null : (_) => fallback!,
    );
  }
}
