part of 'projects_cubit.dart';

class ProjectsState extends Equatable {
  final CustomState<List<ProjectSummary>> getProjectsState;

  /// Active type filter. Null means "All".
  final ProjectType? activeFilter;

  const ProjectsState({
    this.getProjectsState = const CustomState<List<ProjectSummary>>.initial(),
    this.activeFilter,
  });

  /// The list after the active filter is applied — derived on the state rather
  /// than in the widget, so the filtering rule lives in one place.
  List<ProjectSummary> get visibleProjects {
    final List<ProjectSummary> all =
        getProjectsState.data ?? const <ProjectSummary>[];
    if (activeFilter == null) return all;
    return all
        .where((ProjectSummary p) => p.type == activeFilter)
        .toList(growable: false);
  }

  /// Types actually present in the data — so the filter row never offers a
  /// chip that would yield an empty list.
  List<ProjectType> get availableTypes {
    final List<ProjectSummary> all =
        getProjectsState.data ?? const <ProjectSummary>[];
    final Set<ProjectType> types = all.map((ProjectSummary p) => p.type).toSet();
    return ProjectType.values
        .where(types.contains)
        .toList(growable: false);
  }

  ProjectsState copyWith({
    CustomState<List<ProjectSummary>>? getProjectsState,
    ProjectType? activeFilter,
    // copyWith cannot otherwise express "set this back to null", which is what
    // selecting the "All" chip needs to do.
    bool clearFilter = false,
  }) => ProjectsState(
    getProjectsState: getProjectsState ?? this.getProjectsState,
    activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
  );

  @override
  List<Object?> get props => <Object?>[getProjectsState, activeFilter];
}
