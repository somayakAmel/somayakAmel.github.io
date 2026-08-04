import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../../../src/service_locator.dart';
import '../../../../src/widgets/max_width_wrapper.dart';
import '../../../../src/widgets/section_state_builder.dart';
import '../../../../src/widgets/tag_chip.dart';
import '../../domain/entities/project_detail.dart';
import '../cubit/project_details_cubit.dart';
import 'image_viewer_screen.dart';
import 'project_details_arguments.dart';

export 'project_details_arguments.dart';

/// One project, in full (PROJECT_SPEC §7.10).
class ProjectDetailsScreen extends StatelessWidget {
  final ProjectDetailsArguments args;

  const ProjectDetailsScreen({super.key, required this.args});

  static const String route = '/project_details';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectDetailsCubit>(
      create: (_) =>
          sl<ProjectDetailsCubit>()..getProjectDetail(args.slug),
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: CustomAppBar(
            // Renders instantly from the summary the list already had, so there
            // is no flash of empty title while the detail file loads.
            title: args.summary?.title.of(context),
            isScrolled: true,
          ),
          body: BlocBuilder<ProjectDetailsCubit, ProjectDetailsState>(
            builder: (BuildContext context, ProjectDetailsState state) =>
                SectionStateBuilder<ProjectDetail>(
                  state: state.getProjectDetailState,
                  onRetry: () => ProjectDetailsCubit.get(
                    context,
                  ).getProjectDetail(args.slug),
                  builder: (BuildContext context, ProjectDetail detail) =>
                      _DetailBody(detail: detail),
                ),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final ProjectDetail detail;

  const _DetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double hPad = context.responsive(
      mobile: PaddingValues.screenPaddingMobile,
      desktop: PaddingValues.screenPaddingDesktop,
    );

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.only(bottom: AppSize.s64.rh),
      child: MaxWidthWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _cover(context),
            AppSize.s32.spaceH,
            CustomText(
              detail.summary.title.of(context),
              fontSize: isMobile
                  ? FontSize.displayMobile
                  : FontSize.h1Desktop,
              fontWeight: FontWeightManager.bold,
              height: LineHeights.heading,
              textAlign: TextAlign.start,
            ),
            AppSize.s8.spaceH,
            CustomText(
              detail.summary.tagline.of(context),
              fontSize: isMobile
                  ? FontSize.bodyLargeMobile
                  : FontSize.bodyLargeDesktop,
              color: context.colors.textSecondary,
              textAlign: TextAlign.start,
            ),
            AppSize.s24.spaceH,
            _MetaRow(detail: detail),
            AppSize.s40.spaceH,
            _prose(context, StringsManager.overview, detail.overview),
            if (detail.responsibilities.isNotEmpty)
              _bullets(
                context,
                StringsManager.responsibilities,
                detail.responsibilities,
              ),
            if (detail.challenges.isNotEmpty) _challenges(context),
            if (detail.techStack.isNotEmpty) _techStack(context),
            if (detail.hasGallery) _gallery(context),
            if (detail.links.hasAny) ...<Widget>[
              AppSize.s40.spaceH,
              _LinksRow(links: detail.links),
            ],
          ],
        ).withPadding(hPad.pSymmetricH),
      ),
    );
  }

  Widget _cover(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(BorderValues.b20),
    child: AspectRatio(
      aspectRatio: context.isMobile ? 4 / 3 : 16 / 9,
      child: CustomImage(
        path: detail.summary.coverPath,
        fit: BoxFit.cover,
        monogram: detail.summary.title.of(context),
        semanticLabel: detail.summary.title.of(context),
      ),
    ),
  );

  Widget _sectionTitle(BuildContext context, String key) => Padding(
    padding: EdgeInsetsDirectional.only(
      top: AppSize.s40.rh,
      bottom: AppSize.s16.rh,
    ),
    child: Semantics(
      header: true,
      child: CustomText(
        key.tr(context),
        fontSize: context.isMobile ? FontSize.h2Mobile : FontSize.h2Desktop,
        fontWeight: FontWeightManager.bold,
        textAlign: TextAlign.start,
      ),
    ),
  );

  Widget _prose(BuildContext context, String key, LocalizedText body) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _sectionTitle(context, key),
      ProseWidth(
        child: CustomText(
          body.of(context),
          fontSize: FontSize.bodyDesktop,
          color: context.colors.textSecondary,
          textAlign: TextAlign.start,
        ),
      ),
    ],
  );

  Widget _bullets(
    BuildContext context,
    String key,
    List<LocalizedText> items,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _sectionTitle(context, key),
      for (final LocalizedText item in items)
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: AppSize.s12.rh),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsetsDirectional.only(top: AppSize.s8.rh),
                child: Container(
                  height: AppSize.s6,
                  width: AppSize.s6,
                  decoration: BoxDecoration(
                    color: context.colors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              AppSize.s12.spaceW,
              Expanded(
                child: CustomText(
                  item.of(context),
                  fontSize: FontSize.bodyDesktop,
                  color: context.colors.textSecondary,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _challenges(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _sectionTitle(context, StringsManager.challenges),
      for (final ChallengeSolution cs in detail.challenges)
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: AppSize.s16.rh),
          child: CustomContainer(
            color: context.colors.surface2,
            borderColor: context.colors.borderSubtle,
            borderRadius: BorderValues.b12.borderAll,
            padding: PaddingValues.p20.pAll,
            alignment: AlignmentDirectional.centerStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomText(
                  cs.challenge.of(context),
                  fontSize: FontSize.bodyDesktop,
                  fontWeight: FontWeightManager.semiBold,
                  textAlign: TextAlign.start,
                ),
                AppSize.s12.spaceH,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomText(
                      '${StringsManager.solutions.tr(context)}  ',
                      fontSize: FontSize.captionDesktop,
                      fontWeight: FontWeightManager.semiBold,
                      color: context.colors.accent,
                    ),
                    Expanded(
                      child: CustomText(
                        cs.solution.of(context),
                        fontSize: FontSize.captionDesktop,
                        color: context.colors.textSecondary,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ],
  );

  Widget _techStack(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _sectionTitle(context, StringsManager.techStack),
      Wrap(
        spacing: AppSize.s8,
        runSpacing: AppSize.s8,
        children: <Widget>[
          for (final String tech in detail.techStack) TagChip(tech),
        ],
      ),
    ],
  );

  /// Horizontally scrolling screenshots; tapping one opens the full-screen
  /// viewer at that index (PROJECT_SPEC §7.10).
  Widget _gallery(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _sectionTitle(context, StringsManager.gallery),
      SizedBox(
        height: AppSize.s320.rh,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: detail.gallery.length,
          separatorBuilder: (_, _) => AppSize.s12.spaceW,
          itemBuilder: (BuildContext context, int index) {
            final GalleryImage image = detail.gallery[index];
            return CustomContainer(
              onTap: () => Navigator.of(context).pushNamed(
                ImageViewerScreen.route,
                arguments: ImageViewerArguments(
                  images: detail.gallery,
                  initialIndex: index,
                ),
              ),
              padding: PaddingValues.zero,
              borderRadius: BorderValues.b12.borderAll,
              borderColor: context.colors.borderSubtle,
              hoverLift: true,
              semanticLabel: image.caption?.of(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(BorderValues.b12),
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: CustomImage(
                    path: image.path,
                    fit: BoxFit.cover,
                    semanticLabel: image.caption?.of(context),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

class _MetaRow extends StatelessWidget {
  final ProjectDetail detail;

  const _MetaRow({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSize.s32,
      runSpacing: AppSize.s16,
      children: <Widget>[
        _item(context, StringsManager.myRole, detail.role.of(context)),
        _item(context, StringsManager.duration, detail.duration.of(context)),
        if (detail.platforms.isNotEmpty)
          _item(
            context,
            StringsManager.platforms,
            detail.platforms
                .map((PlatformKind p) => p.name)
                .join(' · '),
          ),
      ],
    );
  }

  Widget _item(BuildContext context, String labelKey, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      CustomText(
        labelKey.tr(context).toUpperCase(),
        fontSize: FontSize.labelDesktop,
        fontWeight: FontWeightManager.semiBold,
        color: context.colors.textTertiary,
        letterSpacing: 1.1,
        textAlign: TextAlign.start,
      ),
      AppSize.s4.spaceH,
      CustomText(
        value,
        fontSize: FontSize.captionDesktop,
        fontWeight: FontWeightManager.medium,
        textAlign: TextAlign.start,
      ),
    ],
  );
}

class _LinksRow extends StatelessWidget {
  final ProjectLinks links;

  const _LinksRow({required this.links});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSize.s12,
      runSpacing: AppSize.s12,
      children: <Widget>[
        for (final ({ProjectLinkKind kind, String url}) link in links.asList)
          CustomContainer(
            onTap: () => _open(context, link.url),
            isFilled: link.kind == ProjectLinkKind.github,
            color: context.colors.accent,
            padding: (PaddingValues.p12, PaddingValues.p20).pSymmetricVH,
            semanticLabel: _labelKey(link.kind).tr(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  IconsManager.externalLink,
                  size: AppSize.s16,
                  color: link.kind == ProjectLinkKind.github
                      ? context.colors.onAccent
                      : context.colors.accent,
                ),
                AppSize.s8.spaceW,
                CustomText(
                  _labelKey(link.kind).tr(context),
                  fontSize: FontSize.captionDesktop,
                  fontWeight: FontWeightManager.semiBold,
                  color: link.kind == ProjectLinkKind.github
                      ? context.colors.onAccent
                      : context.colors.accent,
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _labelKey(ProjectLinkKind kind) => switch (kind) {
    ProjectLinkKind.github => StringsManager.viewOnGithub,
    ProjectLinkKind.liveDemo => StringsManager.liveDemo,
    ProjectLinkKind.appStore => StringsManager.appStore,
    ProjectLinkKind.playStore => StringsManager.playStore,
  };

  Future<void> _open(BuildContext context, String url) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String copiedMsg = StringsManager.couldNotOpenLink.tr(context);

    final LaunchOutcome outcome = await sl<LinkLauncher>().open(url);

    // [RULE] Guard BuildContext across the async gap (guide §22.6).
    if (outcome == LaunchOutcome.opened) return;
    messenger.showSnackBar(SnackBar(content: Text(copiedMsg)));
  }
}
