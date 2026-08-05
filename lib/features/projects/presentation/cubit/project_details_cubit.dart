import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/custom_state.dart';
import '../../domain/entities/project_detail.dart';
import '../../domain/usecases/get_project_detail_usecase.dart';

part 'project_details_state.dart';

/// A separate cubit from [ProjectsCubit] because it has a different lifetime:
/// one per detail screen, disposed on pop, while the list cubit belongs to
/// whichever screen is showing a list.
class ProjectDetailsCubit extends Cubit<ProjectDetailsState> {
  final GetProjectDetailUsecase _getProjectDetailUsecase;

  ProjectDetailsCubit(this._getProjectDetailUsecase)
    : super(const ProjectDetailsState());

  static ProjectDetailsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  Future<void> getProjectDetail(String slug) async {
    emit(
      state.copyWith(
        getProjectDetailState: const CustomState<ProjectDetail>.loading(),
      ),
    );

    final result = await _getProjectDetailUsecase(slug);

    result.fold(
      (failure) => emit(
        state.copyWith(
          getProjectDetailState: CustomState<ProjectDetail>.failure(
            failure.message ?? 'Unknown error',
          ),
        ),
      ),
      (detail) => emit(
        state.copyWith(
          getProjectDetailState: CustomState<ProjectDetail>.success(detail),
        ),
      ),
    );
  }
}
