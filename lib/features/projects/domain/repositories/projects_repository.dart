import '../entities/project_detail.dart';
import '../entities/project_summary.dart';

abstract class ProjectsRepository {
  /// All projects, in editorial order.
  Future<List<ProjectSummary>> getProjects();

  /// Featured projects only, capped at [limit] when given.
  Future<List<ProjectSummary>> getFeaturedProjects({int? limit});

  /// One project's full detail, by slug.
  Future<ProjectDetail> getProjectDetail(String slug);
}
