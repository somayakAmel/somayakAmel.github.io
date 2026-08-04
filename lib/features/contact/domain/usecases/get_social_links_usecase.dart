import 'package:dartz/dartz.dart';

import '../../../../core/data/try_catch.dart';
import '../../../../core/domain/errors/failures.dart';
import '../../../../core/domain/usecases/base_usecase.dart';
import '../entities/social_link.dart';
import '../repositories/contact_repository.dart';

class GetSocialLinksUsecase
    extends BaseUseCase<List<SocialLink>, GetSocialLinksParams> {
  final ContactRepository _contactRepository;

  GetSocialLinksUsecase(this._contactRepository);

  @override
  Future<Either<Failure, List<SocialLink>>> call(
    GetSocialLinksParams params,
  ) async {
    return tryCatch(
      tryFunction: () => params.footerOnly
          ? _contactRepository.getFooterLinks()
          : _contactRepository.getSocialLinks(),
    );
  }
}

class GetSocialLinksParams {
  final bool footerOnly;

  const GetSocialLinksParams({this.footerOnly = false});

  static const GetSocialLinksParams all = GetSocialLinksParams();

  static const GetSocialLinksParams footer = GetSocialLinksParams(
    footerOnly: true,
  );
}
