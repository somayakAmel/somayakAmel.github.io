import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/data/try_catch.dart';
import '../../../../core/domain/errors/failures.dart';
import '../../../../core/domain/usecases/base_usecase.dart';
import '../entities/skill.dart';
import '../repositories/skills_repository.dart';

/// Fetches competencies grouped by category and technologies in one call.
///
/// One use case rather than two, because both Home sections read the same file
/// and a single call keeps them consistent — and because splitting would mean
/// two cubits racing on the same memoized asset read.
class GetSkillsUsecase extends BaseUseCaseNoParam<SkillsBundle> {
  final SkillsRepository _skillsRepository;

  GetSkillsUsecase(this._skillsRepository);

  @override
  Future<Either<Failure, SkillsBundle>> call() async {
    return tryCatch(
      tryFunction: () async => SkillsBundle(
        competencies: await _skillsRepository.getCompetenciesByCategory(),
        technologies: await _skillsRepository.getTechnologies(),
      ),
    );
  }
}

/// The two shapes the Skills and Tech Stack sections need.
class SkillsBundle extends Equatable {
  final Map<SkillCategory, List<Skill>> competencies;
  final List<Skill> technologies;

  const SkillsBundle({
    required this.competencies,
    required this.technologies,
  });

  bool get isEmpty => competencies.isEmpty && technologies.isEmpty;

  @override
  List<Object?> get props => <Object?>[competencies, technologies];
}
