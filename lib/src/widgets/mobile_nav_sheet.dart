import 'package:flutter/material.dart';

import '../../core/core.dart';
import 'language_toggle.dart';

/// One entry in the mobile navigation sheet.
class NavDestination {
  final String labelKey;
  final VoidCallback onTap;

  const NavDestination({required this.labelKey, required this.onTap});
}

/// The mobile counterpart to the desktop anchor nav (PROJECT_SPEC §5, §12).
///
/// [RULE] Bottom sheets are a Column with `mainAxisSize.min`, a top-rounded
/// container, and always end with a cancel action (guide §11.5).
class MobileNavSheet extends StatelessWidget {
  final List<NavDestination> destinations;

  const MobileNavSheet({super.key, required this.destinations});

  /// Opens the sheet. Each destination pops the sheet BEFORE running its
  /// action, so the scroll-to-anchor animation is not competing with a
  /// dismissing route.
  static Future<void> show(
    BuildContext context,
    List<NavDestination> destinations,
  ) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => MobileNavSheet(destinations: destinations),
  );

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: BorderValues.b20.borderTop.asBorderRadius,
          border: Border.all(color: colors.borderSubtle),
        ),
        padding: PaddingValues.p20.pAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Drag handle.
            Center(
              child: Container(
                width: AppSize.s40.rw,
                height: AppSize.s4,
                decoration: BoxDecoration(
                  color: colors.borderStrong,
                  borderRadius: BorderRadius.circular(BorderValues.bFull),
                ),
              ),
            ),
            AppSize.s20.spaceH,
            for (final NavDestination destination in destinations) ...<Widget>[
              CustomContainer(
                onTap: () {
                  Navigator.of(context).pop();
                  destination.onTap();
                },
                color: colors.surface3,
                borderRadius: BorderValues.b12.borderAll,
                padding: PaddingValues.p16.pAll,
                alignment: AlignmentDirectional.centerStart,
                semanticLabel: destination.labelKey.tr(context),
                child: CustomText(
                  destination.labelKey.tr(context),
                  fontSize: FontSize.bodyDesktop,
                  fontWeight: FontWeightManager.medium,
                  textAlign: TextAlign.start,
                ),
              ),
              AppSize.s8.spaceH,
            ],
            AppSize.s8.spaceH,
            const Center(child: LanguageToggle()),
            AppSize.s8.spaceH,
            CustomContainer(
              onTap: () => Navigator.of(context).pop(),
              transparentButton: true,
              padding: PaddingValues.p12.pAll,
              semanticLabel: StringsManager.closeMenu.tr(context),
              child: CustomText(
                StringsManager.close.tr(context),
                fontSize: FontSize.captionDesktop,
                fontWeight: FontWeightManager.semiBold,
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
