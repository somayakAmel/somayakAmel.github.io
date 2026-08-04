import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../src/service_locator.dart';
import '../../../../src/widgets/max_width_wrapper.dart';
import '../../../../src/widgets/section_container.dart';
import '../../../../src/widgets/section_header.dart';
import '../../../../src/widgets/section_state_builder.dart';
import '../../domain/entities/about.dart';
import '../cubit/about_cubit.dart';
import 'highlight_stat_tile.dart';

/// The About block on Home (PROJECT_SPEC §7.2).
///
/// ## The composition contract
///
/// Each feature exposes exactly ONE `<Feature>Section` widget that is
/// self-sufficient: it provides its own cubit, fetches on mount, and renders
/// its own loading/error states. `HomeScreen` is then an ordered list of these,
/// with no knowledge of any feature's internals — so adding or reordering a
/// Home section is a one-line change (PROJECT_SPEC §10.3).
class AboutSection extends StatelessWidget {
  final GlobalKey? anchorKey;

  const AboutSection({super.key, this.anchorKey});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AboutCubit>(
      // The cascade-to-fetch idiom triggers the initial load inline (§4.5).
      create: (_) => sl<AboutCubit>()..getAbout(),
      child: Builder(
        // Builder so the child gets a context BELOW the provider (§4.5).
        builder: (BuildContext context) => SectionContainer(
          sectionId: 'about',
          anchorKey: anchorKey,
          background: context.colors.surface1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionHeader(
                eyebrowKey: StringsManager.aboutEyebrow,
                titleKey: StringsManager.aboutTitle,
              ),
              AppSize.s32.spaceH,
              BlocBuilder<AboutCubit, AboutState>(
                builder: (BuildContext context, AboutState state) =>
                    SectionStateBuilder<About>(
                      state: state.getAboutState,
                      onRetry: () => AboutCubit.get(context).getAbout(),
                      builder: (BuildContext context, About about) =>
                          _AboutContent(about: about),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  final About about;

  const _AboutContent({required this.about});

  @override
  Widget build(BuildContext context) {
    final bool isWide = context.isWide;

    final Widget bio = CustomText(
      about.bio.of(context),
      fontSize: context.isMobile
          ? FontSize.bodyLargeMobile
          : FontSize.bodyLargeDesktop,
      color: context.colors.textSecondary,
      textAlign: TextAlign.start,
      height: LineHeights.body,
    );

    final Widget stats = _HighlightGrid(highlights: about.highlights);

    // Desktop: bio 2/3, stats 1/3. Mobile: bio then a 2-up stat grid (§12).
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: ProseWidth(child: bio),
          ),
          AppSize.s48.spaceW,
          Expanded(child: stats),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[bio, AppSize.s32.spaceH, stats],
    );
  }
}

class _HighlightGrid extends StatelessWidget {
  final List<Highlight> highlights;

  const _HighlightGrid({required this.highlights});

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) return const SizedBox.shrink();

    // Desktop stacks them vertically beside the bio; mobile uses a 2-up grid.
    if (context.isWide) {
      return Column(
        children: <Widget>[
          for (int i = 0; i < highlights.length; i++) ...<Widget>[
            if (i > 0) AppSize.s12.spaceH,
            HighlightStatTile(highlight: highlights[i]),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: highlights.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSize.s12,
        mainAxisSpacing: AppSize.s12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (BuildContext context, int index) =>
          HighlightStatTile(highlight: highlights[index]),
    );
  }
}
