import '../../../../core/data/json_reader.dart';
import '../../domain/entities/skill.dart';

/// Serialisation for entries in `assets/data/skills.json`.
class SkillModel {
  final String id;
  final String name;
  final SkillKind kind;
  final SkillCategory category;
  final SkillLevel? level;
  final String? logoPath;
  final bool isCore;

  const SkillModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.category,
    this.level,
    this.logoPath,
    this.isCore = false,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    final String? rawLevel = json.strOrNull('level');
    return SkillModel(
      id: json.str('id'),
      name: json.str('name'),
      // [RULE] Unknown enum values fall back rather than throwing (SPEC §8.4).
      kind: enumFromValue(
        SkillKind.values,
        json.strOrNull('kind'),
        fallback: SkillKind.technology,
      ),
      category: enumFromValue(
        SkillCategory.values,
        json.strOrNull('category'),
        fallback: SkillCategory.tools,
      ),
      // Level is genuinely optional — technologies carry none — so an absent
      // value stays null rather than defaulting to a claim of proficiency.
      level: rawLevel == null
          ? null
          : enumFromValue(
              SkillLevel.values,
              rawLevel,
              fallback: SkillLevel.proficient,
            ),
      logoPath: json.strOrNull('logo_path'),
      isCore: json.boolOr('is_core'),
    );
  }

  Skill toEntity() => Skill(
    id: id,
    name: name,
    kind: kind,
    category: category,
    level: level,
    logoPath: logoPath,
    isCore: isCore,
  );
}
