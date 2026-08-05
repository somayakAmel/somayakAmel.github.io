import 'package:flutter/material.dart';

import '../../core/core.dart';

/// Eyebrow + title + optional trailing action, shared by every Home section
/// (PROJECT_SPEC §10.2).
///
/// The eyebrow is a small accent-coloured label above the title. It gives the
/// type hierarchy a third level without another font size, which is what keeps
/// a minimal page from reading flat.
class SectionHeader extends StatelessWidget {
  /// Localization key for the small label above the title.
  final String eyebrowKey;

  /// Localization key for the section title.
  final String titleKey;

  /// Localization key for the trailing action ("View all").
  final String? actionKey;

  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.eyebrowKey,
    required this.titleKey,
    this.actionKey,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isMobile = context.isMobile;

    final Widget titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CustomText(
          eyebrowKey.tr(context),
          fontSize: isMobile ? FontSize.labelMobile : FontSize.labelDesktop,
          fontWeight: FontWeightManager.semiBold,
          color: colors.accent,
          letterSpacing: 1.2,
          textAlign: TextAlign.start,
        ),
        AppSize.s8.spaceH,
        // Screen readers can jump between sections by header (SPEC §14).
        Semantics(
          header: true,
          child: CustomText(
            titleKey.tr(context),
            fontSize: isMobile ? FontSize.h1Mobile : FontSize.h1Desktop,
            fontWeight: FontWeightManager.bold,
            height: LineHeights.heading,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );

    if (actionKey == null || onActionTap == null) {
      return titleBlock;
    }

    final Widget action = CustomContainer(
      onTap: onActionTap,
      transparentButton: true,
      padding: (PaddingValues.p8, PaddingValues.p12).pSymmetricVH,
      semanticLabel: actionKey!.tr(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomText(
            actionKey!.tr(context),
            fontSize: FontSize.captionDesktop,
            fontWeight: FontWeightManager.semiBold,
            color: colors.accent,
          ),
          AppSize.s4.spaceW,
          // Mirrors in RTL — Directionality alone would not flip a raw
          // arrow glyph (SPEC risk R-6).
          Icon(
            context.isRtl ? IconsManager.back : IconsManager.forward,
            size: AppSize.s16,
            color: colors.accent,
          ),
        ],
      ),
    );

    // On mobile the action drops below the title rather than competing with it
    // for horizontal space.
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[titleBlock, AppSize.s8.spaceH, action],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[Expanded(child: titleBlock), action],
    );
  }
}
