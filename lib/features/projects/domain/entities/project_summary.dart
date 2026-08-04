import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/localized_text.dart';

/// Card-shaped project data, from `projects/index.json` (PROJECT_SPEC §8.3).
///
/// ## Why this is separate from ProjectDetail
///
/// The list screen never loads challenge/solution prose it will not render.
/// That is a real domain distinction, and it mirrors the list/detail split any
/// real API would have (SPEC §4). It is also what makes the one-file-per-project
/// layout workable: the index is small and always loaded; detail files are
/// loaded one at a time, on demand.
class ProjectSummary extends Equatable {
  final String slug;
  final LocalizedText title;
  final LocalizedText tagline;
  final LocalizedText domain;
  final String? coverPath;
  final ProjectType type;
  final List<String> primaryTech;
  final bool isFeatured;
  final int order;

  /// Path to this project's detail JSON. Explicit rather than derived from
  /// [slug], so a renamed file fails loudly instead of 404-ing silently.
  final String detailFile;

  const ProjectSummary({
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

  @override
  List<Object?> get props => <Object?>[
    slug,
    title,
    tagline,
    domain,
    coverPath,
    type,
    primaryTech,
    isFeatured,
    order,
    detailFile,
  ];
}

enum ProjectType {
  product,
  client,
  openSource,
  personal;

  /// Localization key for the filter chip label.
  String get labelKey => switch (this) {
    ProjectType.product => 'typeProduct',
    ProjectType.client => 'typeClient',
    ProjectType.openSource => 'typeOpenSource',
    ProjectType.personal => 'typePersonal',
  };
}
