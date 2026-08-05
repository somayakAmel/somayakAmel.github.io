import 'package:flutter/material.dart';

import '../../extensions/responsive_extension.dart';
import '../../managers/fonts_manager.dart';
import '../theme/app_color_scheme.dart';

/// All text rendering (ARCHITECTURE_GUIDE §11.2).
///
/// [RULE] Never use a raw Flutter `Text` in feature code.
///
/// [RULE] The text is the positional first argument; everything else is named
/// (§16, authoring rule 4).
class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;
  final double? letterSpacing;
  final TextDecoration? decoration;
  final bool selectable;

  const CustomText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.letterSpacing,
    this.decoration,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontFamily: FontConstants.fontFamily,
      fontSize: (fontSize ?? FontSize.bodyDesktop).rs,
      fontWeight: fontWeight ?? FontWeightManager.regular,
      color: color ?? context.colors.textPrimary,
      height: height ?? LineHeights.body,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: color ?? context.colors.textPrimary,
    );

    // Selectable text matters on Web: a recruiter copying an email address or
    // a company name should not be blocked by canvas rendering.
    if (selectable) {
      return SelectableText(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
      );
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
    );
  }
}
