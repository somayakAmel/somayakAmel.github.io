part of 'experience_cubit.dart';

class ExperienceState extends Equatable {
  final CustomState<List<Experience>> getExperienceState;

  const ExperienceState({
    this.getExperienceState = const CustomState<List<Experience>>.initial(),
  });

  ExperienceState copyWith({
    CustomState<List<Experience>>? getExperienceState,
  }) => ExperienceState(
    getExperienceState: getExperienceState ?? this.getExperienceState,
  );

  @override
  List<Object?> get props => <Object?>[getExperienceState];
}
