import '../../domain/entities/project_summary.dart';

/// [RULE] Multi-argument routes take a dedicated `<Screen>Arguments` class,
/// cast once in `generateRoute` (ARCHITECTURE_GUIDE §9.4).
///
/// [summary] is optional because a direct URL entry or page refresh on Web
/// arrives with no arguments at all — only the slug from the query string. When
/// it IS present (the normal in-app navigation path), the detail screen renders
/// its header immediately instead of flashing an empty title while the detail
/// file loads (PROJECT_SPEC §5).
class ProjectDetailsArguments {
  final String slug;
  final ProjectSummary? summary;

  const ProjectDetailsArguments({required this.slug, this.summary});
}
