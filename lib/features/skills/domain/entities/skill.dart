import 'package:equatable/equatable.dart';

import '../../../../core/managers/strings_manager.dart';

/// A capability or a technology (PROJECT_SPEC §8.3).
///
/// One entity backs both Home sections. [kind] partitions them: Skills renders
/// competencies grouped by category with a proficiency signal; Tech Stack
/// renders technologies as a dense logo grid with neither (SPEC §4).
class Skill extends Equatable {
  final String id;

  /// Not localized: technology and competency names are proper nouns that are
  /// not translated in either language (PROJECT_SPEC §9).
  final String name;

  final SkillKind kind;
  final SkillCategory category;
  final SkillLevel? level;
  final String? logoPath;

  const Skill({
    required this.id,
    required this.name,
    required this.kind,
    required this.category,
    this.level,
    this.logoPath,
  });

  @override
  List<Object?> get props => <Object?>[id, name, kind, category, level, logoPath];
}

enum SkillKind { competency, technology }

enum SkillCategory {
  mobile,
  architecture,
  stateManagement,
  backend,
  tools,
  practices;

  String get labelKey => switch (this) {
    SkillCategory.mobile => StringsManager.categoryMobile,
    SkillCategory.architecture => StringsManager.categoryArchitecture,
    SkillCategory.stateManagement => StringsManager.categoryStateManagement,
    SkillCategory.backend => StringsManager.categoryBackend,
    SkillCategory.tools => StringsManager.categoryTools,
    SkillCategory.practices => StringsManager.categoryPractices,
  };
}

/// A coarse three-step scale, deliberately not a percentage.
///
/// Self-assessed percentages ("Flutter 95%") read as unserious to an engineer
/// reviewing the portfolio and are unfalsifiable; a coarse scale is honest
/// (PROJECT_SPEC §7.4).
enum SkillLevel {
  familiar,
  proficient,
  expert;

  /// Filled segments out of three.
  int get filledSegments => index + 1;

  String get labelKey => switch (this) {
    SkillLevel.familiar => StringsManager.levelFamiliar,
    SkillLevel.proficient => StringsManager.levelProficient,
    SkillLevel.expert => StringsManager.levelExpert,
  };
}
