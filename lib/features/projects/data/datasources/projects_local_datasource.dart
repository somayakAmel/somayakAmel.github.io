import '../../../../core/data/json_reader.dart';
import '../../../../core/data/local_json_datasource.dart';
import '../../../../core/domain/errors/exceptions.dart';
import '../../../../core/managers/assets_manager.dart';
import '../models/project_detail_model.dart';
import '../models/project_summary_model.dart';

abstract class ProjectsLocalDatasource {
  Future<List<ProjectSummaryModel>> getProjectIndex();

  Future<ProjectDetailModel> getProjectDetail(String detailFile);
}

class ProjectsLocalDatasourceImpl implements ProjectsLocalDatasource {
  final LocalJsonDataSource _jsonDataSource;

  ProjectsLocalDatasourceImpl(this._jsonDataSource);

  @override
  Future<List<ProjectSummaryModel>> getProjectIndex() async {
    final Map<String, dynamic> json = await _jsonDataSource.readJson(
      AssetsManager.projectsIndexData,
    );

    final List<ProjectSummaryModel> projects = json
        .objList('projects')
        .map(ProjectSummaryModel.fromJson)
        // A malformed entry with no slug cannot be routed to, so it is dropped
        // rather than rendered as a dead card.
        .where((ProjectSummaryModel p) => p.slug.trim().isNotEmpty)
        .toList();

    // Editorial ordering, explicit in the JSON rather than
    // alphabetical-by-filename (PROJECT_SPEC §4).
    projects.sort(
      (ProjectSummaryModel a, ProjectSummaryModel b) =>
          a.order.compareTo(b.order),
    );

    return projects;
  }

  @override
  Future<ProjectDetailModel> getProjectDetail(String detailFile) async {
    final Map<String, dynamic> json = await _jsonDataSource.readJson(
      detailFile,
    );
    return ProjectDetailModel.fromJson(json);
  }
}

/// Thrown when an index entry points at a detail file whose `slug` does not
/// match — which means `detail_file` is mis-wired and the wrong project would
/// render (PROJECT_SPEC §9).
class ProjectSlugMismatchException extends AppException {
  const ProjectSlugMismatchException(super.message);
}
