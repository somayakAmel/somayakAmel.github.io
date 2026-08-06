import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show IconData;

import '../../../../core/managers/icons_manager.dart';
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

  /// True for skills used across most of the portfolio's projects.
  ///
  /// [RULE] This is DERIVED FROM EVIDENCE, not self-assessed: a skill is core
  /// when it appears in at least four of the six project tech stacks. That
  /// keeps the badge defensible in an interview — the claim is "I used this on
  /// most of my work", which the project pages themselves corroborate — and
  /// avoids the invented proficiency ratings the design brief rules out.
  final bool isCore;

  const Skill({
    required this.id,
    required this.name,
    required this.kind,
    required this.category,
    this.level,
    this.logoPath,
    this.isCore = false,
  });

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    kind,
    category,
    level,
    logoPath,
    isCore,
  ];
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

  /// One line under the category title, giving the group a reason to exist
  /// rather than leaving it a bare header.
  String get descriptionKey => switch (this) {
    SkillCategory.mobile => StringsManager.categoryMobileDesc,
    SkillCategory.architecture => StringsManager.categoryArchitectureDesc,
    SkillCategory.stateManagement =>
      StringsManager.categoryStateManagementDesc,
    SkillCategory.backend => StringsManager.categoryBackendDesc,
    SkillCategory.tools => StringsManager.categoryToolsDesc,
    SkillCategory.practices => StringsManager.categoryPracticesDesc,
  };

  /// Material glyph for the category header.
  ///
  /// Material icons rather than brand SVGs: the set is already bundled and
  /// tree-shaken, so this costs nothing and carries no trademark questions.
  /// Individual skills fall back to monogram tiles until brand logos are added
  /// to assets/logos/ and referenced by logo_path.
  IconData get icon => switch (this) {
    SkillCategory.mobile => IconsManager.devices,
    SkillCategory.architecture => IconsManager.layers,
    SkillCategory.stateManagement => IconsManager.stateManagement,
    SkillCategory.backend => IconsManager.cloud,
    SkillCategory.tools => IconsManager.tools,
    SkillCategory.practices => IconsManager.verified,
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
