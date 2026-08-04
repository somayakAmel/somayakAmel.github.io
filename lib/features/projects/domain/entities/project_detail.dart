import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/localized_text.dart';
import 'project_summary.dart';

/// Full project data, from `projects/<slug>.json` (PROJECT_SPEC §8.3).
///
/// Composes its [summary] rather than duplicating those fields, so the detail
/// screen renders its header from data the list already had — no flash of empty
/// title while the detail file loads.
class ProjectDetail extends Equatable {
  final ProjectSummary summary;
  final LocalizedText overview;
  final LocalizedText role;
  final LocalizedText duration;
  final List<PlatformKind> platforms;
  final ProjectStatus status;
  final List<LocalizedText> responsibilities;
  final List<ChallengeSolution> challenges;
  final List<String> techStack;
  final List<GalleryImage> gallery;
  final ProjectLinks links;

  const ProjectDetail({
    required this.summary,
    required this.overview,
    required this.role,
    required this.duration,
    required this.status,
    this.platforms = const <PlatformKind>[],
    this.responsibilities = const <LocalizedText>[],
    this.challenges = const <ChallengeSolution>[],
    this.techStack = const <String>[],
    this.gallery = const <GalleryImage>[],
    this.links = const ProjectLinks(),
  });

  String get slug => summary.slug;

  bool get hasGallery => gallery.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
    summary,
    overview,
    role,
    duration,
    platforms,
    status,
    responsibilities,
    challenges,
    techStack,
    gallery,
    links,
  ];
}

/// A challenge paired with how it was solved.
///
/// Modelled as a PAIR rather than two independent lists: a challenge with no
/// matching solution is the most common way this section reads badly
/// (PROJECT_SPEC §7.10).
class ChallengeSolution extends Equatable {
  final LocalizedText challenge;
  final LocalizedText solution;

  const ChallengeSolution({required this.challenge, required this.solution});

  @override
  List<Object?> get props => <Object?>[challenge, solution];
}

class GalleryImage extends Equatable {
  final String path;
  final LocalizedText? caption;

  const GalleryImage({required this.path, this.caption});

  @override
  List<Object?> get props => <Object?>[path, caption];
}

class ProjectLinks extends Equatable {
  final String? github;
  final String? liveDemo;
  final String? appStore;
  final String? playStore;

  const ProjectLinks({
    this.github,
    this.liveDemo,
    this.appStore,
    this.playStore,
  });

  bool get hasAny =>
      github != null || liveDemo != null || appStore != null || playStore != null;

  /// Ordered non-null entries, so the links row renders uniformly without the
  /// widget branching on each field.
  List<({ProjectLinkKind kind, String url})> get asList =>
      <({ProjectLinkKind kind, String url})>[
        if (github != null) (kind: ProjectLinkKind.github, url: github!),
        if (liveDemo != null) (kind: ProjectLinkKind.liveDemo, url: liveDemo!),
        if (appStore != null) (kind: ProjectLinkKind.appStore, url: appStore!),
        if (playStore != null)
          (kind: ProjectLinkKind.playStore, url: playStore!),
      ];

  @override
  List<Object?> get props => <Object?>[github, liveDemo, appStore, playStore];
}

enum ProjectLinkKind { github, liveDemo, appStore, playStore }

enum ProjectStatus { live, inDevelopment, archived }

enum PlatformKind { android, ios, web, desktop }
