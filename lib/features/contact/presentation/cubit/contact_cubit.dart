import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/custom_state.dart';
import '../../domain/entities/social_link.dart';
import '../../domain/usecases/get_social_links_usecase.dart';

part 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  final GetSocialLinksUsecase _getSocialLinksUsecase;

  ContactCubit(this._getSocialLinksUsecase) : super(const ContactState());

  static ContactCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> getSocialLinks({
    GetSocialLinksParams params = GetSocialLinksParams.all,
  }) async {
    emit(
      state.copyWith(
        getSocialLinksState: const CustomState<List<SocialLink>>.loading(),
      ),
    );

    final result = await _getSocialLinksUsecase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          getSocialLinksState: CustomState<List<SocialLink>>.failure(
            failure.message ?? 'Unknown error',
          ),
        ),
      ),
      (links) => emit(
        state.copyWith(
          getSocialLinksState: CustomState<List<SocialLink>>.success(links),
        ),
      ),
    );
  }
}
