part of 'project_details_cubit.dart';

class ProjectDetailsState extends Equatable {
  final CustomState<ProjectDetail> getProjectDetailState;

  const ProjectDetailsState({
    this.getProjectDetailState = const CustomState<ProjectDetail>.initial(),
  });

  ProjectDetailsState copyWith({
    CustomState<ProjectDetail>? getProjectDetailState,
  }) => ProjectDetailsState(
    getProjectDetailState: getProjectDetailState ?? this.getProjectDetailState,
  );

  @override
  List<Object?> get props => <Object?>[getProjectDetailState];
}
