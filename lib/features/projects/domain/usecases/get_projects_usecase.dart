import 'package:dartz/dartz.dart';

import '../../../../core/data/try_catch.dart';
import '../../../../core/domain/errors/failures.dart';
import '../../../../core/domain/usecases/base_usecase.dart';
import '../entities/project_summary.dart';
import '../repositories/projects_repository.dart';

/// Fetches the project list, optionally featured-only.
///
/// [RULE] The body is only the `tryCatch` wrapper — the featured/limit policy
/// lives in the repository (guide Rule 6).
class GetProjectsUsecase
    extends BaseUseCase<List<ProjectSummary>, GetProjectsParams> {
  final ProjectsRepository _projectsRepository;

  GetProjectsUsecase(this._projectsRepository);

  @override
  Future<Either<Failure, List<ProjectSummary>>> call(
    GetProjectsParams params,
  ) async {
    return tryCatch(
      tryFunction: () => params.featuredOnly
          ? _projectsRepository.getFeaturedProjects(limit: params.limit)
          : _projectsRepository.getProjects(),
    );
  }
}

/// [RULE] The params class lives in the same file, below the use case
/// (guide §2.6).
class GetProjectsParams {
  final bool featuredOnly;
  final int? limit;

  const GetProjectsParams({this.featuredOnly = false, this.limit});

  static const GetProjectsParams all = GetProjectsParams();

  static const GetProjectsParams featured = GetProjectsParams(
    featuredOnly: true,
    limit: 3,
  );
}
