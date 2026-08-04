import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../src/widgets/animated_counter.dart';
import '../../domain/entities/about.dart';

/// One headline stat — "5+ / Years Experience" (PROJECT_SPEC §7.2).
class HighlightStatTile extends StatelessWidget {
  final Highlight highlight;

  const HighlightStatTile({super.key, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isMobile = context.isMobile;

    return CustomContainer(
      color: colors.surface2,
      borderColor: colors.borderSubtle,
      borderRadius: BorderValues.b16.borderAll,
      padding: PaddingValues.p20.pAll,
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (highlight.iconKey != null) ...<Widget>[
            Icon(
              IconsManager.fromKey(highlight.iconKey),
              size: AppSize.s20,
              color: colors.accent,
            ),
            AppSize.s12.spaceH,
          ],
          AnimatedCounter(
            highlight.value,
            fontSize: isMobile ? FontSize.h2Mobile : FontSize.h2Desktop,
          ),
          AppSize.s4.spaceH,
          CustomText(
            highlight.label.of(context),
            fontSize: isMobile ? FontSize.labelMobile : FontSize.captionDesktop,
            color: colors.textSecondary,
            textAlign: TextAlign.start,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
