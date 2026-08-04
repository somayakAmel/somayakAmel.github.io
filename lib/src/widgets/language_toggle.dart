import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../core/localization/locale_cubit.dart';

/// Switches between the two supported languages (PROJECT_SPEC §5).
///
/// The app bar hosts this instead of a Settings screen: with dark-mode-only in
/// v1, language is the single setting, and a whole screen holding one switch
/// would be a screen too many.
///
/// The label shows the language you would switch TO — `switchLanguage` resolves
/// to "العربية" in the English file and "English" in the Arabic one, so the
/// control reads correctly in both directions without any branching here.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String label = StringsManager.switchLanguage.tr(context);

    return CustomContainer(
      onTap: () => LocaleCubit.get(context).toggleLang(),
      transparentButton: true,
      padding: (PaddingValues.p8, PaddingValues.p12).pSymmetricVH,
      semanticLabel: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            IconsManager.language,
            size: AppSize.s16,
            color: colors.textSecondary,
          ),
          AppSize.s6.spaceW,
          CustomText(
            label,
            fontSize: FontSize.captionDesktop,
            fontWeight: FontWeightManager.medium,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
