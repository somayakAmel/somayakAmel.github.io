part of 'about_cubit.dart';

/// [RULE] One state class per cubit, holding one `CustomState<T>` field per
/// independent async operation (guide §3.2, Rule 17).
///
/// [RULE] The state field name matches the cubit method name: `getAbout()`
/// mutates `getAboutState` (Rule 18).
///
/// [RULE] Extends `Equatable`, lists every field in `props`, and every field
/// defaults to `const CustomState.initial()` so the cubit's super call is bare.
class AboutState extends Equatable {
  final CustomState<About> getAboutState;

  const AboutState({this.getAboutState = const CustomState<About>.initial()});

  AboutState copyWith({CustomState<About>? getAboutState}) =>
      AboutState(getAboutState: getAboutState ?? this.getAboutState);

  @override
  List<Object?> get props => <Object?>[getAboutState];
}
