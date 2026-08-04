import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/custom_state.dart';
import '../../domain/usecases/get_skills_usecase.dart';

part 'skills_state.dart';

class SkillsCubit extends Cubit<SkillsState> {
  final GetSkillsUsecase _getSkillsUsecase;

  SkillsCubit(this._getSkillsUsecase) : super(const SkillsState());

  static SkillsCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> getSkills() async {
    emit(
      state.copyWith(getSkillsState: const CustomState<SkillsBundle>.loading()),
    );

    final result = await _getSkillsUsecase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          getSkillsState: CustomState<SkillsBundle>.failure(
            failure.message ?? 'Unknown error',
          ),
        ),
      ),
      (bundle) => emit(
        state.copyWith(
          getSkillsState: CustomState<SkillsBundle>.success(bundle),
        ),
      ),
    );
  }
}
