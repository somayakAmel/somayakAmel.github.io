import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/custom_state.dart';
import '../../domain/entities/experience.dart';
import '../../domain/usecases/get_experience_usecase.dart';

part 'experience_state.dart';

class ExperienceCubit extends Cubit<ExperienceState> {
  final GetExperienceUsecase _getExperienceUsecase;

  ExperienceCubit(this._getExperienceUsecase) : super(const ExperienceState());

  static ExperienceCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> getExperience() async {
    emit(
      state.copyWith(
        getExperienceState: const CustomState<List<Experience>>.loading(),
      ),
    );

    final result = await _getExperienceUsecase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          getExperienceState: CustomState<List<Experience>>.failure(
            failure.message ?? 'Unknown error',
          ),
        ),
      ),
      (items) => emit(
        state.copyWith(
          getExperienceState: CustomState<List<Experience>>.success(items),
        ),
      ),
    );
  }
}
