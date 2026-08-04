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
                      onRetry: () => ProjectsCubit.get(context).getProjects(
                        params: GetProjectsParams.featured,
                      ),
                      builder:
                          (BuildContext context, List<ProjectSummary> projects) =>
                              ProjectsLayout(projects: projects),
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
class ProjectsLayout extends StatelessWidget {
  final List<ProjectSummary> projects;

  const ProjectsLayout({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) return _MobileCarousel(projects: projects);

    final int columns = context.responsive(
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSize.s24,
        mainAxisSpacing: AppSize.s24,
        // Tuned so a 2-line tagline plus a chip row never overflows.
        childAspectRatio: 0.82,
      ),
      itemBuilder: (BuildContext context, int index) =>
          _card(context, projects[index]),
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
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // [RULE] Controllers are created in initState and disposed in dispose —
    // never in build(). This is the leak the guide flags in §22.18.
    _controller = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Column(
      children: <Widget>[
        SizedBox(
          height: AppSize.s400.rh,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.projects.length,
            onPageChanged: (int index) => setState(() => _page = index),
            itemBuilder: (BuildContext context, int index) => Padding(
              padding: PaddingValues.p6.pSymmetricH,
              child: _card(context, widget.projects[index]),
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
  }
}

Widget _card(BuildContext context, ProjectSummary project) => ProjectCard(
  project: project,
  onTap: () => Navigator.of(context).pushNamed(
    ProjectDetailsScreen.route,
    arguments: ProjectDetailsArguments(slug: project.slug, summary: project),
  ),
);
