import '../../../../core/data/json_reader.dart';
import '../../../../core/domain/entities/localized_text.dart';
import '../../domain/entities/project_summary.dart';

/// Serialisation for entries in `assets/data/projects/index.json`.
class ProjectSummaryModel {
  final String slug;
  final LocalizedText title;
  final LocalizedText tagline;
  final LocalizedText domain;
  final String? coverPath;
  final ProjectType type;
  final List<String> primaryTech;
  final bool isFeatured;
  final int order;
  final String detailFile;

  const ProjectSummaryModel({
    required this.slug,
    required this.title,
    required this.tagline,
    required this.domain,
    required this.type,
    required this.detailFile,
    this.coverPath,
    this.primaryTech = const <String>[],
    this.isFeatured = false,
    this.order = 0,
  });

  factory ProjectSummaryModel.fromJson(Map<String, dynamic> json) {
    final String slug = json.str('slug');
    return ProjectSummaryModel(
      slug: slug,
      title: json.localized('title'),
      tagline: json.localized('tagline'),
      domain: json.localized('domain'),
      coverPath: json.strOrNull('cover_path'),
      // [RULE] Unknown enum values fall back rather than throwing (SPEC §8.4).
      type: enumFromValue(
        ProjectType.values,
        json.strOrNull('type'),
        fallback: ProjectType.personal,
      ),
      primaryTech: json.strList('primary_tech'),
      isFeatured: json.boolOr('is_featured'),
      order: json.intOr('order'),
      // Falls back to the conventional path when the field is omitted, so a
      // minimal index entry still resolves.
      detailFile:
          json.strOrNull('detail_file') ?? 'assets/data/projects/$slug.json',
    );
  }

  ProjectSummary toEntity() => ProjectSummary(
    slug: slug,
    title: title,
    tagline: tagline,
    domain: domain,
    coverPath: coverPath,
    type: type,
    primaryTech: primaryTech,
    isFeatured: isFeatured,
    order: order,
    detailFile: detailFile,
  );
}
