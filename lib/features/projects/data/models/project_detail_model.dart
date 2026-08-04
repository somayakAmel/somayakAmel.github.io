import '../../../../core/data/json_reader.dart';
import '../../../../core/domain/entities/localized_text.dart';
import '../../domain/entities/project_detail.dart';
import '../../domain/entities/project_summary.dart';

/// Serialisation for `assets/data/projects/<slug>.json`.
class ProjectDetailModel {
  final String slug;
  final LocalizedText overview;
  final LocalizedText role;
  final LocalizedText duration;
  final List<PlatformKind> platforms;
  final ProjectStatus status;
  final List<LocalizedText> responsibilities;
  final List<ChallengeSolutionModel> challenges;
  final List<String> techStack;
  final List<GalleryImageModel> gallery;
  final ProjectLinksModel links;

  const ProjectDetailModel({
    required this.slug,
    required this.overview,
    required this.role,
    required this.duration,
    required this.status,
    this.platforms = const <PlatformKind>[],
    this.responsibilities = const <LocalizedText>[],
    this.challenges = const <ChallengeSolutionModel>[],
    this.techStack = const <String>[],
    this.gallery = const <GalleryImageModel>[],
    this.links = const ProjectLinksModel(),
  });

  factory ProjectDetailModel.fromJson(Map<String, dynamic> json) =>
      ProjectDetailModel(
        slug: json.str('slug'),
        overview: json.localized('overview'),
        role: json.localized('role'),
        duration: json.localized('duration'),
        platforms: json
            .strList('platforms')
            .map(
              (String e) => enumFromValue(
                PlatformKind.values,
                e,
                fallback: PlatformKind.android,
              ),
            )
            .toList(growable: false),
        status: enumFromValue(
          ProjectStatus.values,
          json.strOrNull('status'),
          fallback: ProjectStatus.live,
        ),
        responsibilities: json.localizedList('responsibilities'),
        challenges: json
            .objList('challenges')
            .map(ChallengeSolutionModel.fromJson)
            .toList(growable: false),
        techStack: json.strList('tech_stack'),
        gallery: json
            .objList('gallery')
            .map(GalleryImageModel.fromJson)
            .toList(growable: false),
        links: ProjectLinksModel.fromJson(json.obj('links')),
      );

  /// Needs the [summary] because [ProjectDetail] composes it — the detail file
  /// holds only the fields the index does not.
  ProjectDetail toEntity(ProjectSummary summary) => ProjectDetail(
    summary: summary,
    overview: overview,
    role: role,
    duration: duration,
    platforms: platforms,
    status: status,
    responsibilities: responsibilities,
    challenges: challenges
        .map((ChallengeSolutionModel e) => e.toEntity())
        .toList(growable: false),
    techStack: techStack,
    gallery: gallery
        .map((GalleryImageModel e) => e.toEntity())
        .toList(growable: false),
    links: links.toEntity(),
  );
}

class ChallengeSolutionModel {
  final LocalizedText challenge;
  final LocalizedText solution;

  const ChallengeSolutionModel({
    required this.challenge,
    required this.solution,
  });

  factory ChallengeSolutionModel.fromJson(Map<String, dynamic> json) =>
      ChallengeSolutionModel(
        challenge: json.localized('challenge'),
        solution: json.localized('solution'),
      );

  ChallengeSolution toEntity() =>
      ChallengeSolution(challenge: challenge, solution: solution);
}

class GalleryImageModel {
  final String path;
  final LocalizedText? caption;

  const GalleryImageModel({required this.path, this.caption});

  factory GalleryImageModel.fromJson(Map<String, dynamic> json) {
    final LocalizedText caption = json.localized('caption');
    return GalleryImageModel(
      path: json.str('path'),
      caption: caption.isEmpty ? null : caption,
    );
  }

  GalleryImage toEntity() => GalleryImage(path: path, caption: caption);
}

class ProjectLinksModel {
  final String? github;
  final String? liveDemo;
  final String? appStore;
  final String? playStore;

  const ProjectLinksModel({
    this.github,
    this.liveDemo,
    this.appStore,
    this.playStore,
  });

  factory ProjectLinksModel.fromJson(Map<String, dynamic> json) =>
      ProjectLinksModel(
        github: json.strOrNull('github'),
        liveDemo: json.strOrNull('live_demo'),
        appStore: json.strOrNull('app_store'),
        playStore: json.strOrNull('play_store'),
      );

  ProjectLinks toEntity() => ProjectLinks(
    github: github,
    liveDemo: liveDemo,
    appStore: appStore,
    playStore: playStore,
  );
}
