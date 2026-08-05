import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../extensions/responsive_extension.dart';
import '../../extensions/spacing_extension.dart';
import '../../managers/fonts_manager.dart';
import '../../managers/icons_manager.dart';
import '../../managers/values_manager.dart';
import '../theme/app_color_scheme.dart';
import 'custom_container.dart';
import 'custom_text.dart';

/// App bar (ARCHITECTURE_GUIDE §11.4), extended to host the desktop anchor nav
/// and the language toggle (PROJECT_SPEC §10.1).
///
/// It becomes opaque with a hairline border once the page scrolls beneath it,
/// so content never bleeds into the bar on a long scrolling page.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  /// Rendered in place of [title] — used by Home for the wordmark.
  final Widget? leadingWidget;

  /// Desktop anchor nav and the language toggle.
  final List<Widget> actions;

  /// Shows a circular back button. Defaults to whatever the navigator can pop.
  final bool? showBack;

  /// True once the page has scrolled — switches to the opaque treatment.
  final bool isScrolled;

  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    this.title,
    this.leadingWidget,
    this.actions = const <Widget>[],
    this.showBack,
    this.isScrolled = false,
    this.onBack,
  });

  static const double height = AppSize.s64;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool canPop = showBack ?? Navigator.of(context).canPop();

    // Glass is deliberately rare (design system §Glass Effect): the navbar,
    // floating buttons, dialogs, and the image viewer — never a whole page.
    // The blur only engages once content is actually passing beneath the bar;
    // over the hero it would frost empty background for no reason.
    final Widget bar = AnimatedContainer(
      duration: context.reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 200),
      height: height.rh,
      decoration: BoxDecoration(
        // Translucent rather than opaque, so the blur has something to do.
        color: isScrolled
            ? colors.surface0.withValues(alpha: 0.72)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isScrolled ? colors.borderSubtle : Colors.transparent,
            width: AppSize.s1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: <Widget>[
            if (canPop) ...<Widget>[
              CustomContainer(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
                shape: BoxShape.circle,
                color: colors.surface2,
                padding: PaddingValues.p8.pAll,
                semanticLabel: MaterialLocalizations.of(
                  context,
                ).backButtonTooltip,
                child: Icon(
                  IconsManager.back,
                  size: AppSize.s20,
                  color: colors.textPrimary,
                ),
              ),
              AppSize.s12.spaceW,
            ],
            if (leadingWidget != null)
              leadingWidget!
            else if (title != null)
              CustomText(
                title!,
                fontSize: FontSize.h3Desktop,
                fontWeight: FontWeightManager.bold,
                height: LineHeights.tight,
              ),
            const Spacer(),
            ...actions,
          ],
        ).withPadding(
          context
              .responsive(
                mobile: PaddingValues.screenPaddingMobile,
                desktop: PaddingValues.screenPaddingDesktop,
              )
              .pSymmetricH,
        ),
      ),
    );

    if (!isScrolled) return bar;

    // ClipRect bounds the blur to the bar; without it the filter samples the
    // whole layer and costs far more on Web.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: bar,
      ),
    );
  }
}
