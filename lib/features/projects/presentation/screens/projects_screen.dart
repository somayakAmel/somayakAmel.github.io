import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../src/service_locator.dart';
import '../../../../src/widgets/max_width_wrapper.dart';
import '../../../../src/widgets/section_state_builder.dart';
import '../../../../src/widgets/tag_chip.dart';
import '../../domain/entities/project_summary.dart';
import '../cubit/projects_cubit.dart';
import '../widgets/featured_projects_section.dart';

/// All projects, filterable by type (PROJECT_SPEC §6, S3).
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  /// [RULE] Every routable screen declares its route as its first member
  /// (guide §9.2).
  static const String route = '/projects';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectsCubit>(
      create: (_) => sl<ProjectsCubit>()..getProjects(),
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: CustomAppBar(
            title: StringsManager.allProjects.tr(context),
            isScrolled: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(
              top: AppSize.s24.rh,
              bottom: AppSize.s64.rh,
            ),
            child: MaxWidthWrapper(
              child: BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (BuildContext context, ProjectsState state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (state.getProjectsState.isSuccess)
                        _FilterRow(state: state),
                      AppSize.s24.spaceH,
                      SectionStateBuilder<List<ProjectSummary>>(
                        state: state.getProjectsState,
                        onRetry: () =>
                            ProjectsCubit.get(context).getProjects(),
                        isEmpty: (_) => state.visibleProjects.isEmpty,
                        empty: SectionEmptyState(
                          title: StringsManager.noProjects.tr(context),
                        ),
                        // Renders the FILTERED list, not the raw payload.
                        builder: (BuildContext context, _) =>
                            ProjectsLayout(projects: state.visibleProjects),
                      ),
                    ],
                  ).withPadding(
                    context
                        .responsive(
                          mobile: PaddingValues.screenPaddingMobile,
                          desktop: PaddingValues.screenPaddingDesktop,
                        )
                        .pSymmetricH,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final ProjectsState state;

  const _FilterRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final List<ProjectType> types = state.availableTypes;
    // A filter row with one option is noise.
    if (types.length < 2) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSize.s8,
      runSpacing: AppSize.s8,
      children: <Widget>[
        TagChip(
          StringsManager.filterAll.tr(context),
          isSelected: state.activeFilter == null,
          onTap: () => ProjectsCubit.get(context).setFilter(null),
        ),
        for (final ProjectType type in types)
          TagChip(
            type.labelKey.tr(context),
            isSelected: state.activeFilter == type,
            onTap: () => ProjectsCubit.get(context).setFilter(type),
          ),
      ],
    );
  }
}
