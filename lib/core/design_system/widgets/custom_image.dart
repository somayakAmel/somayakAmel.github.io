import 'package:flutter/material.dart';

import '../../extensions/common_extensions.dart';
import '../../extensions/responsive_extension.dart';
import '../../managers/fonts_manager.dart';
import '../../managers/values_manager.dart';
import '../theme/app_color_scheme.dart';
import 'custom_svg.dart';
import 'custom_text.dart';

/// Unified image rendering (ARCHITECTURE_GUIDE §11.4).
///
/// Simplified from the guide (PROJECT_SPEC §10.1): no `CachedNetworkImage` and
/// no file variant, because every image in this app ships in the bundle. What
/// remains is asset raster, asset SVG, and a graceful fallback.
///
/// [RULE] The grid must never show a broken-image box. A missing asset renders
/// [fallback], or a monogram tile when one is supplied (SPEC §7.5).
class CustomImage extends StatelessWidget {
  final String? path;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;

  /// Rendered when [path] is null or fails to load.
  final Widget? fallback;

  /// First letter shown in the default fallback tile — for a technology or
  /// company whose logo is absent.
  final String? monogram;

  /// Description for screen readers.
  ///
  /// [RULE] Every image has a semantic label or is explicitly decorative
  /// (SPEC §14). Pass null only for ornamental imagery.
  final String? semanticLabel;

  const CustomImage({
    super.key,
    this.path,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.color,
    this.fallback,
    this.monogram,
    this.semanticLabel,
  });

  bool get _isSvg => path != null && path!.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    final Widget image = _buildImage(context);

    final Widget clipped = borderRadius == null
        ? image
        : ClipRRect(
            borderRadius: borderRadius!.resolve(Directionality.of(context)),
            child: image,
          );

    if (semanticLabel == null) return clipped.decorative;
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(child: clipped),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (path == null || path!.isBlank) return _fallback(context);

    if (_isSvg) {
      return CustomSvg(
        path!,
        height: height,
        width: width,
        color: color,
        fit: fit,
        fallback: _fallback(context),
      );
    }

    return Image.asset(
      path!,
      height: height?.rh,
      width: width?.rw,
      fit: fit,
      color: color,
      // A missing asset degrades to the fallback rather than throwing a red
      // box — a content typo should never break a section.
      errorBuilder: (BuildContext _, Object error, StackTrace? _) {
        error.dLog('CustomImage failed: $path');
        return _fallback(context);
      },
    );
  }

  Widget _fallback(BuildContext context) {
    if (fallback != null) return fallback!;

    final AppColorScheme colors = context.colors;
    return Container(
      height: height?.rh,
      width: width?.rw,
      decoration: BoxDecoration(
        color: colors.surface3,
        borderRadius: borderRadius?.resolve(Directionality.of(context)),
      ),
      alignment: Alignment.center,
      child: monogram.isNotNullOrBlank
          ? CustomText(
              monogram!.substring(0, 1).toUpperCase(),
              fontSize: FontSize.h2Desktop,
              fontWeight: FontWeightManager.bold,
              color: colors.textTertiary,
            )
          : Icon(
              Icons.image_outlined,
              color: colors.textTertiary,
              size: AppSize.s24,
            ),
    );
  }
}
