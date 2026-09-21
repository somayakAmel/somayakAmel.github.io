import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../src/service_locator.dart';
import '../../../../src/widgets/section_container.dart';
import '../../../../src/widgets/section_header.dart';
import '../../../../src/widgets/section_state_builder.dart';
import '../../domain/entities/project_summary.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import '../cubit/projects_cubit.dart';
import '../screens/project_details_screen.dart';
import '../screens/projects_screen.dart';
import 'project_card.dart';

/// The active card's share of the rail width on a phone. The remainder is the
/// sliver of the next card that signals the rail scrolls.
const double _cardFraction = 0.88;

/// The Featured Projects block on Home (PROJECT_SPEC §7.3).
///
/// The strongest evidence on the page, placed third so a recruiter scrolling
/// for fifteen seconds reaches it early (SPEC §4).
class FeaturedProjectsSection extends StatelessWidget {
  final GlobalKey? anchorKey;

  const FeaturedProjectsSection({super.key, this.anchorKey});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectsCubit>(
      create: (_) =>
          sl<ProjectsCubit>()..getProjects(params: GetProjectsParams.featured),
      child: Builder(
        builder: (BuildContext context) => SectionContainer(
          sectionId: 'projects',
          anchorKey: anchorKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionHeader(
                eyebrowKey: StringsManager.projectsEyebrow,
                titleKey: StringsManager.projectsTitle,
                actionKey: StringsManager.viewAll,
                onActionTap: () =>
                    Navigator.of(context).pushNamed(ProjectsScreen.route),
              ),
              AppSize.s32.spaceH,
              BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (BuildContext context, ProjectsState state) =>
                    SectionStateBuilder<List<ProjectSummary>>(
                      state: state.getProjectsState,
                      isEmpty: (List<ProjectSummary> p) => p.isEmpty,
                      empty: SectionEmptyState(
                        title: StringsManager.noProjects.tr(context),
                      ),
                      onRetry: () => ProjectsCubit.get(
                        context,
                      ).getProjects(params: GetProjectsParams.featured),
                      builder:
                          (
                            BuildContext context,
                            List<ProjectSummary> projects,
                          ) => ProjectsLayout(projects: projects),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Responsive project layout, shared by the Home section and /projects
/// (PROJECT_SPEC §12): 3-col desktop, 2-col tablet, swipeable carousel on
/// mobile — which reads better on a phone than a tall vertical stack.
///
/// ## [RULE] Nothing here gives a card a height
///
/// A card is sized by its own content; a row or the rail then takes the height
/// of the tallest card in it. Both halves of this widget used to pin a height
/// instead, and both overflowed:
///
///  - the grid set `childAspectRatio: 0.82`, which is a fixed height written
///    as a ratio of the width — it cannot know how tall the text under the
///    cover is;
///  - the rail set `SizedBox(height: AppSize.s400.rh)`, which was worse,
///    because `.rh` scales by VIEWPORT HEIGHT. A short phone got LESS room for
///    content that had not shrunk at all, so the shorter the device the bigger
///    the overflow — 72px at 320x568, 90px at 430x932.
///
/// No height guess survives a longer tagline, a chip row that wraps, or a
/// larger system font, so there is no guess to tune here. Measure instead.
class ProjectsLayout extends StatelessWidget {
  final List<ProjectSummary> projects;

  const ProjectsLayout({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) return _MobileCarousel(projects: projects);

    final int columns = context.responsive(mobile: 1, tablet: 2, desktop: 3);

    // Rows of IntrinsicHeight rather than a GridView: every grid tile is a
    // fixed size by construction. This measures the tallest card in each row
    // and gives its siblings that height, so the cards still line up.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (
          int start = 0;
          start < projects.length;
          start += columns
        ) ...<Widget>[
          if (start > 0) AppSize.s24.spaceH,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = start; i < start + columns; i++) ...<Widget>[
                  if (i > start) AppSize.s24.spaceW,
                  // The empty slots in a short final row hold the remaining
                  // cards to the same width as the rows above them.
                  Expanded(
                    child: i < projects.length
                        ? _card(context, projects[i])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MobileCarousel extends StatefulWidget {
  final List<ProjectSummary> projects;

  const _MobileCarousel({required this.projects});

  @override
  State<_MobileCarousel> createState() => _MobileCarouselState();
}

class _MobileCarouselState extends State<_MobileCarousel> {
  late final ScrollController _controller;

  /// Leading edge to leading edge, one card to the next. Written during
  /// layout, because it depends on the measured viewport, and read by the
  /// scroll listener to turn an offset into a page index.
  double _itemExtent = 1;

  int _page = 0;

  @override
  void initState() {
    super.initState();
    // [RULE] Controllers are created in initState and disposed in dispose —
    // never in build(). This is the leak the guide flags in §22.18.
    _controller = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final int page = (_controller.offset / _itemExtent).round().clamp(
      0,
      widget.projects.length - 1,
    );
    if (page == _page) return;
    setState(() => _page = page);
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double viewport = constraints.maxWidth;
        final double gap = AppSize.s12.rw;
        final double cardWidth = viewport * _cardFraction - gap;
        _itemExtent = cardWidth + gap;

        // Half the leftover width at each end centres the first and last card
        // exactly as the old PageView's viewportFraction did, and lands
        // maxScrollExtent on a whole number of items so snapping is exact.
        final double endInset = (viewport - cardWidth) / 2;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _controller,
              physics: _SnapScrollPhysics(itemExtent: _itemExtent),
              padding: EdgeInsetsDirectional.symmetric(horizontal: endInset),
              // A scroll view measures its cross axis from its child, so this
              // is what makes the rail exactly as tall as the tallest card.
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (
                      int i = 0;
                      i < widget.projects.length;
                      i++
                    ) ...<Widget>[
                      if (i > 0) AppSize.s12.spaceW,
                      SizedBox(
                        width: cardWidth,
                        child: _card(context, widget.projects[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (widget.projects.length > 1) ...<Widget>[
              AppSize.s16.spaceH,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < widget.projects.length; i++)
                    AnimatedContainer(
                      duration: DurationValues.dm250.milliseconds,
                      margin: EdgeInsetsDirectional.symmetric(
                        horizontal: AppSize.s4.rw,
                      ),
                      height: AppSize.s6,
                      width: i == _page ? AppSize.s20.rw : AppSize.s6.rw,
                      decoration: BoxDecoration(
                        color: i == _page ? colors.accent : colors.borderStrong,
                        borderRadius: BorderRadius.circular(BorderValues.bFull),
                      ),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Snaps the rail to whole cards on release.
///
/// This is the one thing PageView gave for free that a scroll view does not,
/// and it is the whole price of dropping PageView — which had to be paid,
/// because a PageView is a viewport and a viewport must be handed a height.
class _SnapScrollPhysics extends ScrollPhysics {
  final double itemExtent;

  const _SnapScrollPhysics({required this.itemExtent, super.parent});

  @override
  _SnapScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _SnapScrollPhysics(itemExtent: itemExtent, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final Tolerance tolerance = toleranceFor(position);

    // Leave the overscroll bounce at either end to the platform physics.
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final double current = position.pixels / itemExtent;
    // A deliberate flick always advances a whole card; a slow release settles
    // on whichever card is nearest.
    final double targetIndex = velocity.abs() < tolerance.velocity
        ? current.roundToDouble()
        : (velocity > 0 ? current.ceilToDouble() : current.floorToDouble());

    final double target = (targetIndex * itemExtent).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if ((target - position.pixels).abs() < tolerance.distance) return null;

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }
}

Widget _card(BuildContext context, ProjectSummary project) => ProjectCard(
  project: project,
  onTap: () => Navigator.of(context).pushNamed(
    ProjectDetailsScreen.route,
    arguments: ProjectDetailsArguments(slug: project.slug, summary: project),
  ),
);
