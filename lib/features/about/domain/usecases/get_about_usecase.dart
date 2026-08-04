import 'package:dartz/dartz.dart';

import '../../../../core/data/try_catch.dart';
import '../../../../core/domain/errors/failures.dart';
import '../../../../core/domain/usecases/base_usecase.dart';
import '../entities/about.dart';
import '../repositories/about_repository.dart';

/// [RULE] One use case per file, named `<verb>_<noun>_usecase.dart`, taking its
/// repository as the only constructor dependency, with a body that is only the
/// `tryCatch` wrapper (guide §2.6, Rule 6).
class GetAboutUsecase extends BaseUseCaseNoParam<About> {
  final AboutRepository _aboutRepository;

  GetAboutUsecase(this._aboutRepository);

  @override
  Future<Either<Failure, About>> call() async {
    return tryCatch(tryFunction: () => _aboutRepository.getAbout());
  }
}
