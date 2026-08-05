import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/custom_state.dart';
import '../../domain/entities/project_summary.dart';
import '../../domain/usecases/get_projects_usecase.dart';

part 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final GetProjectsUsecase _getProjectsUsecase;

  ProjectsCubit(this._getProjectsUsecase) : super(const ProjectsState());

  static ProjectsCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> getProjects({
    GetProjectsParams params = GetProjectsParams.all,
  }) async {
    emit(
      state.copyWith(
        getProjectsState: const CustomState<List<ProjectSummary>>.loading(),
      ),
    );

    final result = await _getProjectsUsecase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          getProjectsState: CustomState<List<ProjectSummary>>.failure(
            failure.message ?? 'Unknown error',
          ),
        ),
      ),
      (projects) => emit(
        state.copyWith(
          getProjectsState: CustomState<List<ProjectSummary>>.success(projects),
        ),
      ),
    );
  }

  /// Changes the active type filter.
  ///
  /// Filtering is local to already-loaded data, so this is a synchronous state
  /// change with no refetch — every project is in memory.
  void setFilter(ProjectType? type) =>
      emit(state.copyWith(activeFilter: type, clearFilter: type == null));
}
