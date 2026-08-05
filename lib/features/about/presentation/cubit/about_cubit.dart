import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/custom_state.dart';
import '../../domain/entities/about.dart';
import '../../domain/usecases/get_about_usecase.dart';

part 'about_state.dart';

/// [RULE] Cubits only — never Blocs with events (guide §3, Rule 16).
/// The method call on the cubit *is* the event.
class AboutCubit extends Cubit<AboutState> {
  final GetAboutUsecase _getAboutUsecase;

  /// [RULE] Dependencies are private fields injected positionally (§3.4).
  AboutCubit(this._getAboutUsecase) : super(const AboutState());

  /// [RULE] Every cubit exposes this accessor, so call sites read
  /// `AboutCubit.get(context).getAbout()` (§3.4, Rule 20).
  static AboutCubit get(BuildContext context) => BlocProvider.of(context);

  /// [RULE] Emit loading → await use case → fold → emit (§3.4, Rule 26).
  Future<void> getAbout() async {
    emit(state.copyWith(getAboutState: const CustomState<About>.loading()));

    final result = await _getAboutUsecase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          getAboutState: CustomState<About>.failure(
            failure.message ?? 'Unknown error',
          ),
        ),
      ),
      (about) =>
          emit(state.copyWith(getAboutState: CustomState<About>.success(about))),
    );
  }
}
