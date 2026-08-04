import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../../../src/service_locator.dart';
import '../../../../src/widgets/max_width_wrapper.dart';
import '../../../about/domain/entities/about.dart';
import '../../../about/presentation/cubit/about_cubit.dart';
import '../../../projects/presentation/screens/projects_screen.dart';

/// The Hero block (PROJECT_SPEC §7.1).
///
/// Answers "who is this" in under three seconds: name, role, years, positioning
/// statement, and two CTAs. A recruiter scanning for 20 seconds must get all of
/// it without scrolling.
///
/// Hero reads `about.json` but does not own it — it provides its own
/// [AboutCubit] instance, separate from the About section's. Both resolve to
/// the same memoized asset read, so there is no double parse (SPEC §16).
class HeroSection extends StatelessWidget {
  final VoidCallback? onScrollToWork;

  const HeroSection({super.key, this.onScrollToWork});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AboutCubit>(
      create: (_) => sl<AboutCubit>()..getAbout(),
      child: Builder(
        builder: (BuildContext context) =>
            BlocBuilder<AboutCubit, AboutState>(
              builder: (BuildContext context, AboutState state) {
                final About? about = state.getAboutState.data;

                // Above the fold: a skeleton, never a spinner. And on failure a
                // static fallback rather than an error card — a broken hero is
                // the worst possible first impression (SPEC §7.1).
                return _HeroContent(
                  about: about,
                  onScrollToWork: onScrollToWork,
                );
              },
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

    final Widget text = Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (about != null) ...<Widget>[
          CustomText(
            about!.roleTitle.of(context).toUpperCase(),
            fontSize: FontSize.labelDesktop,
            fontWeight: FontWeightManager.semiBold,
            color: colors.accent,
            letterSpacing: 1.4,
            textAlign: isWide ? TextAlign.start : TextAlign.center,
          ),
          AppSize.s16.spaceH,
          CustomText(
            about!.name.of(context),
            fontSize: isMobile
                ? FontSize.displayMobile
                : FontSize.displayDesktop,
            fontWeight: FontWeightManager.bold,
            height: LineHeights.tight,
            textAlign: isWide ? TextAlign.start : TextAlign.center,
          ),
          AppSize.s20.spaceH,
          ProseWidth(
            child: CustomText(
              about!.tagline.of(context),
              fontSize: isMobile
                  ? FontSize.bodyLargeMobile
                  : FontSize.bodyLargeDesktop,
              color: colors.textSecondary,
              textAlign: isWide ? TextAlign.start : TextAlign.center,
            ),
          ),
        ] else
          const _HeroSkeleton(),
        AppSize.s32.spaceH,
        Wrap(
          spacing: AppSize.s12,
          runSpacing: AppSize.s12,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: <Widget>[
            CustomContainer(
              text: StringsManager.viewMyWork.tr(context),
              onTap: onScrollToWork ??
                  () => Navigator.of(context).pushNamed(ProjectsScreen.route),
              padding: (PaddingValues.p16, PaddingValues.p32).pSymmetricVH,
              hoverLift: true,
            ),
            if (about?.hasResume ?? false)
              CustomContainer(
                text: StringsManager.downloadResume.tr(context),
                onTap: () => _openResume(context, about!.resumePath!),
                isFilled: false,
                color: colors.textPrimary,
                padding: (PaddingValues.p16, PaddingValues.p32).pSymmetricVH,
              ),
          ],
        ),
      ],
    );

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        // Sized so the first project card peeks above the fold on a 900px-tall
        // laptop viewport. A hero that fills the screen hides the proof, which
        // is the exact failure mode SPEC §7.1 warns about.
        minHeight: isWide ? AppSize.s480.rh : 0,
      ),
      padding: EdgeInsetsDirectional.only(
        top: AppSize.s96.rh,
        bottom: AppSize.s48.rh,
      ),
      child: MaxWidthWrapper(
        // The wrapper centres the clamped 1200px column on the page; the
        // SizedBox makes that column full-width so the inner Column's
        // crossAxisAlignment (start on desktop, center on mobile) governs
        // where the text sits WITHIN it. Without the SizedBox the Column
        // shrink-wraps and its own alignment has nothing to align against.
        child: SizedBox(
          width: double.infinity,
          child: text.withPadding(hPad.pSymmetricH),
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

/// Matches the final layout's shape so there is no reflow when content lands.
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
        borderRadius: BorderRadius.circular(BorderValues.b8),
      ),
    );

    return Column(
      crossAxisAlignment: context.isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        bar(AppSize.s160, AppSize.s14),
        bar(AppSize.s400, AppSize.s56),
        bar(AppSize.s320, AppSize.s20),
      ],
    );
  }
}
