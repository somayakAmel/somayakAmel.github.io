part of 'skills_cubit.dart';

class SkillsState extends Equatable {
  final CustomState<SkillsBundle> getSkillsState;

  const SkillsState({
    this.getSkillsState = const CustomState<SkillsBundle>.initial(),
  });

  SkillsState copyWith({CustomState<SkillsBundle>? getSkillsState}) =>
      SkillsState(getSkillsState: getSkillsState ?? this.getSkillsState);

  @override
  List<Object?> get props => <Object?>[getSkillsState];
}
