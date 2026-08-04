import 'package:flutter/material.dart';

import '../../extensions/spacing_extension.dart';
import '../../localization/app_localizations.dart';
import '../../managers/fonts_manager.dart';
import '../../managers/icons_manager.dart';
import '../../managers/strings_manager.dart';
import '../../managers/values_manager.dart';
import '../theme/app_color_scheme.dart';
import 'custom_container.dart';
import 'custom_text.dart';

/// Section-level error with a retry action (ARCHITECTURE_GUIDE §8.5).
///
/// [RULE] The failure branch must always offer a retry that re-invokes the same
/// fetch (§3.7, Rule 22).
class CustomErrorWidget extends StatelessWidget {
  final String? error;
  final VoidCallback onTap;
  final bool compact;

  const CustomErrorWidget({
    super.key,
    required this.onTap,
    this.error,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          IconsManager.error,
          color: colors.danger,
          size: compact ? AppSize.s24 : AppSize.s32,
        ),
        AppSize.s12.spaceH,
        CustomText(
          StringsManager.somethingWentWrong.tr(context),
          fontSize: compact ? FontSize.captionDesktop : FontSize.h3Desktop,
          fontWeight: FontWeightManager.semiBold,
          textAlign: TextAlign.center,
        ),
        // The raw message is developer-facing detail. Shown in debug only —
        // a visitor should never read an exception string.
        if (error != null && !compact) ...<Widget>[
          AppSize.s8.spaceH,
          CustomText(
            error!,
            fontSize: FontSize.captionDesktop,
            color: colors.textTertiary,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ],
        AppSize.s20.spaceH,
        CustomContainer(
          text: StringsManager.tryAgain.tr(context),
          onTap: onTap,
          isFilled: false,
          color: colors.accent,
          textFont: FontSize.captionDesktop,
          padding: (PaddingValues.p10, PaddingValues.p20).pSymmetricVH,
        ),
      ],
    );
  }
}
