import '../../../../core/domain/errors/exceptions.dart';
import '../../../../core/extensions/common_extensions.dart';
import '../../domain/entities/project_detail.dart';
import '../../domain/entities/project_summary.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_local_datasource.dart';
import '../models/project_detail_model.dart';
import '../models/project_summary_model.dart';

/// The reference repository implementation.
///
/// This is where the index/detail composition happens: a detail lookup first
/// resolves the summary from the index, then loads that entry's detail file and
/// merges the two. The cubit never knows there are two files.
class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsLocalDatasource _localDatasource;

  ProjectsRepositoryImpl(this._localDatasource);

  @override
  Future<List<ProjectSummary>> getProjects() async {
    final List<ProjectSummaryModel> models = await _localDatasource
        .getProjectIndex();
    return models
        .map((ProjectSummaryModel e) => e.toEntity())
        .toList(growable: false);
  }

  @override
  Future<List<ProjectSummary>> getFeaturedProjects({int? limit}) async {
    final List<ProjectSummary> all = await getProjects();
    final List<ProjectSummary> featured = all
        .where((ProjectSummary p) => p.isFeatured)
        .toList();

    // Filtering belongs here, not in the cubit or the use case: it is a data
    // policy decision, and putting it here keeps the use case a bare tryCatch
    // wrapper (guide Rule 6).
    if (limit != null && featured.length > limit) {
      return featured.sublist(0, limit);
    }
    return featured;
  }

  @override
  Future<ProjectDetail> getProjectDetail(String slug) async {
    final List<ProjectSummaryModel> index = await _localDatasource
        .getProjectIndex();

    final ProjectSummaryModel? summary = index
        .where((ProjectSummaryModel p) => p.slug == slug)
        .firstOrNull;

    if (summary == null) {
      throw NotFoundException('No project in the index with slug "$slug".');
    }

    final ProjectDetailModel detail = await _localDatasource.getProjectDetail(
      summary.detailFile,
    );

    // The slug is duplicated across index and detail on purpose: asserting they
    // match catches a mis-wired detail_file immediately, rather than silently
    // rendering the wrong project (PROJECT_SPEC §9).
    if (detail.slug.isNotBlank && detail.slug != slug) {
      throw ProjectSlugMismatchException(
        'Index entry "$slug" points at "${summary.detailFile}", '
        'which declares slug "${detail.slug}".',
      );
    }

    return detail.toEntity(summary.toEntity());
  }
}
