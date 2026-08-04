part of 'contact_cubit.dart';

class ContactState extends Equatable {
  final CustomState<List<SocialLink>> getSocialLinksState;

  const ContactState({
    this.getSocialLinksState = const CustomState<List<SocialLink>>.initial(),
  });

  ContactState copyWith({
    CustomState<List<SocialLink>>? getSocialLinksState,
  }) => ContactState(
    getSocialLinksState: getSocialLinksState ?? this.getSocialLinksState,
  );

  @override
  List<Object?> get props => <Object?>[getSocialLinksState];
}
