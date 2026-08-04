import 'package:dartz/dartz.dart';

import '../../../../core/data/try_catch.dart';
import '../../../../core/domain/errors/failures.dart';
import '../../../../core/domain/usecases/base_usecase.dart';
import '../entities/project_detail.dart';
import '../repositories/projects_repository.dart';

/// Fetches one project's full detail by slug.
///
/// Takes the slug directly rather than a params object, per the guide: for a
/// single primitive argument, pass it directly (§2.6).
class GetProjectDetailUsecase extends BaseUseCase<ProjectDetail, String> {
  final ProjectsRepository _projectsRepository;

  GetProjectDetailUsecase(this._projectsRepository);

  @override
  Future<Either<Failure, ProjectDetail>> call(String params) async {
    return tryCatch(
      tryFunction: () => _projectsRepository.getProjectDetail(params),
    );
  }
}
