import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../../../src/service_locator.dart';
import '../../../../src/widgets/ambient_glow.dart';
import '../../../../src/widgets/max_width_wrapper.dart';
import '../../../about/domain/entities/about.dart';
import '../../../about/presentation/cubit/about_cubit.dart';
import '../../../projects/presentation/screens/projects_screen.dart';

/// The Hero block (PROJECT_SPEC §7.1, design system §Hero).
///
/// Minimal by intent: huge type, generous whitespace, two CTAs, and the ambient
/// glow. No illustration, no laptop mockup, no coding GIF — the message is
/// "this engineer builds production software", and stock imagery undercuts it.
class HeroSection extends StatelessWidget {
  final VoidCallback? onScrollToWork;

  const HeroSection({super.key, this.onScrollToWork});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AboutCubit>(
      create: (_) => sl<AboutCubit>()..getAbout(),
      child: Builder(
        builder: (BuildContext context) => BlocBuilder<AboutCubit, AboutState>(
          builder: (BuildContext context, AboutState state) => _HeroContent(
            about: state.getAboutState.data,
            onScrollToWork: onScrollToWork,
          ),
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final About? about;
  final VoidCallback? onScrollToWork;

  const _HeroContent({required this.about, this.onScrollToWork});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isMobile = context.isMobile;
    final bool isWide = context.isWide;

    final double hPad = context.responsive(
      mobile: PaddingValues.screenPaddingMobile,
      desktop: PaddingValues.screenPaddingDesktop,
    );

    return AmbientGlow(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          // Tall enough to feel composed, short enough that the first project
          // card peeks above the fold on a 900px laptop — a hero that fills the
          // screen hides the proof (SPEC §7.1).
          minHeight: isWide ? AppSize.s600.rh : 0,
        ),
        padding: EdgeInsetsDirectional.only(
          top: AppSize.s120.rh,
          // Mobile has no scroll indicator, so a desktop-sized bottom pad
          // leaves a dead gap between the CTA and the first project card.
          bottom: (isWide ? AppSize.s80 : AppSize.s48).rh,
        ),
        child: MaxWidthWrapper(
          child: SizedBox(
            width: double.infinity,
            child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (about != null) ...<Widget>[
                      CustomText(
                        StringsManager.heroGreeting.tr(context),
                        fontSize: isMobile
                            ? FontSize.bodyLargeMobile
                            : FontSize.bodyLargeDesktop,
                        color: colors.textSecondary,
                        textAlign: TextAlign.start,
                      ),
                      AppSize.s8.spaceH,
                      CustomText.display(
                        about!.name.of(context),
                        fontSize: isMobile
                            ? FontSize.displayMobile
                            : FontSize.displayDesktop,
                        height: LineHeights.display,
                        letterSpacing: LetterSpacings.display,
                        textAlign: TextAlign.start,
                      ),
                      AppSize.s12.spaceH,
                      CustomText(
                        about!.roleTitle.of(context),
                        fontSize: isMobile
                            ? FontSize.h2Mobile
                            : FontSize.h1Desktop,
                        fontWeight: FontWeightManager.medium,
                        color: colors.accent,
                        height: LineHeights.heading,
                        textAlign: TextAlign.start,
                      ),
                      AppSize.s24.spaceH,
                      ProseWidth(
                        child: CustomText(
                          about!.tagline.of(context),
                          fontSize: isMobile
                              ? FontSize.bodyMobile
                              : FontSize.bodyLargeDesktop,
                          color: colors.textSecondary,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ] else
                      const _HeroSkeleton(),
                    AppSize.s40.spaceH,
                    Wrap(
                      spacing: AppSize.s12,
                      runSpacing: AppSize.s12,
                      children: <Widget>[
                        CustomContainer(
                          text: StringsManager.viewMyWork.tr(context),
                          onTap:
                              onScrollToWork ??
                              () => Navigator.of(
                                context,
                              ).pushNamed(ProjectsScreen.route),
                          padding: (PaddingValues.p16, PaddingValues.p32)
                              .pSymmetricVH,
                          borderRadius: BorderValues.small.borderAll,
                          hoverLift: true,
                          glow: true,
                        ),
                        if (about?.hasResume ?? false)
                          CustomContainer(
                            text: StringsManager.downloadResume.tr(context),
                            onTap: () =>
                                _openResume(context, about!.resumePath!),
                            isFilled: false,
                            color: colors.textPrimary,
                            borderColor: colors.borderStrong,
                            borderRadius: BorderValues.small.borderAll,
                            padding: (PaddingValues.p16, PaddingValues.p32)
                                .pSymmetricVH,
                            hoverLift: true,
                          ),
                      ],
                    ),
                    if (isWide) ...<Widget>[
                      AppSize.s64.spaceH,
                      const _ScrollIndicator(),
                    ],
                  ],
                ).withPadding(hPad.pSymmetricH),
          ),
        ),
      ),
    );
  }

  Future<void> _openResume(BuildContext context, String path) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String failMsg = StringsManager.couldNotOpenLink.tr(context);
    final LaunchOutcome outcome = await sl<LinkLauncher>().open(path);
    if (outcome == LaunchOutcome.opened) return;
    messenger.showSnackBar(SnackBar(content: Text(failMsg)));
  }
}

/// The only looping animation in the app (SPEC §13).
class _ScrollIndicator extends StatefulWidget {
  const _ScrollIndicator();

  @override
  State<_ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<_ScrollIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Row(
      children: <Widget>[
        AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) => Transform.translate(
            offset: Offset(0, _controller.value * AppSize.s8),
            child: child,
          ),
          child: Icon(
            IconsManager.scrollDown,
            size: AppSize.s20,
            color: colors.textTertiary,
          ),
        ),
        AppSize.s8.spaceW,
        CustomText(
          StringsManager.scrollToExplore.tr(context),
          fontSize: FontSize.labelDesktop,
          color: colors.textTertiary,
          letterSpacing: LetterSpacings.label,
        ),
      ],
    );
  }
}

/// Matches the final layout's shape so nothing reflows when content lands.
class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    Widget bar(double w, double h) => Container(
      width: w.rw,
      height: h.rh,
      margin: EdgeInsetsDirectional.only(bottom: AppSize.s16.rh),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(BorderValues.small),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        bar(AppSize.s120, AppSize.s20),
        bar(AppSize.s480, AppSize.s64),
        bar(AppSize.s320, AppSize.s32),
        bar(AppSize.s400, AppSize.s20),
      ],
    );
  }
}
