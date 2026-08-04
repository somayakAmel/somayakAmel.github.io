import '../entities/skill.dart';

abstract class SkillsRepository {
  /// All skills, both kinds.
  Future<List<Skill>> getSkills();

  /// Competencies only, grouped by category in declaration order.
  Future<Map<SkillCategory, List<Skill>>> getCompetenciesByCategory();

  /// Technologies only, for the Tech Stack grid.
  Future<List<Skill>> getTechnologies();
}
