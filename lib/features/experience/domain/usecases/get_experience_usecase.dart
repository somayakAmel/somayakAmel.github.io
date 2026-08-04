import 'package:dartz/dartz.dart';

import '../../../../core/data/try_catch.dart';
import '../../../../core/domain/errors/failures.dart';
import '../../../../core/domain/usecases/base_usecase.dart';
import '../entities/experience.dart';
import '../repositories/experience_repository.dart';

class GetExperienceUsecase extends BaseUseCaseNoParam<List<Experience>> {
  final ExperienceRepository _experienceRepository;

  GetExperienceUsecase(this._experienceRepository);

  @override
  Future<Either<Failure, List<Experience>>> call() async {
    return tryCatch(tryFunction: () => _experienceRepository.getExperience());
  }
}
