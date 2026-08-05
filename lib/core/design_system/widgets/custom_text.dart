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
/// Which family a piece of text belongs to.
///
/// [RULE] Anything that acts as a headline is [TextRole.display]; everything
/// else is [TextRole.body]. The role picks the family, so call sites never name
/// a font directly.
enum TextRole { display, body }

class CustomText extends StatelessWidget {
  final String text;
  final TextRole role;
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
    this.role = TextRole.body,
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

  /// Convenience for headline text — hero type, section titles, card titles.
  const CustomText.display(
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
  }) : role = TextRole.display;

  @override
  Widget build(BuildContext context) {
    final bool isDisplay = role == TextRole.display;

    final TextStyle style = TextStyle(
      fontFamily: isDisplay
          ? FontConstants.displayFamily
          : FontConstants.bodyFamily,
      fontSize: (fontSize ?? FontSize.bodyDesktop).rs,
      fontWeight:
          fontWeight ??
          (isDisplay ? FontWeightManager.bold : FontWeightManager.regular),
      color: color ?? context.colors.textPrimary,
      height: height ?? (isDisplay ? LineHeights.heading : LineHeights.body),
      // Display type needs negative tracking or it reads loose at large sizes.
      letterSpacing:
          letterSpacing ?? (isDisplay ? LetterSpacings.heading : null),
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
