import '../../domain/entities/skill.dart';
import '../../domain/repositories/skills_repository.dart';
import '../datasources/skills_local_datasource.dart';
import '../models/skill_model.dart';

class SkillsRepositoryImpl implements SkillsRepository {
  final SkillsLocalDatasource _localDatasource;

  SkillsRepositoryImpl(this._localDatasource);

  @override
  Future<List<Skill>> getSkills() async {
    final List<SkillModel> models = await _localDatasource.getSkills();
    return models.map((SkillModel e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<Map<SkillCategory, List<Skill>>> getCompetenciesByCategory() async {
    final List<Skill> all = await getSkills();

    // Grouping is a data-shaping decision, so it lives here rather than in the
    // cubit or the widget (guide Rule 6 keeps use cases logic-free).
    final Map<SkillCategory, List<Skill>> grouped =
        <SkillCategory, List<Skill>>{};

    // Iterating the enum rather than the data fixes group order to the
    // declaration order, so the section does not reshuffle when the JSON is
    // reordered.
    for (final SkillCategory category in SkillCategory.values) {
      final List<Skill> inCategory = all
          .where(
            (Skill s) => s.kind == SkillKind.competency && s.category == category,
          )
          .toList(growable: false);
      if (inCategory.isNotEmpty) grouped[category] = inCategory;
    }

    return grouped;
  }

  @override
  Future<List<Skill>> getTechnologies() async {
    final List<Skill> all = await getSkills();
    return all
        .where((Skill s) => s.kind == SkillKind.technology)
        .toList(growable: false);
  }
}
