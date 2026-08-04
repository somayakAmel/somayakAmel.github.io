import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/features/skills/data/datasources/skills_local_datasource.dart';
import 'package:portfolio/features/skills/data/models/skill_model.dart';
import 'package:portfolio/features/skills/data/repositories/skills_repository_impl.dart';
import 'package:portfolio/features/skills/domain/entities/skill.dart';

class _MockDatasource extends Mock implements SkillsLocalDatasource {}

SkillModel _skill(
  String id, {
  required SkillKind kind,
  SkillCategory category = SkillCategory.mobile,
  SkillLevel? level,
}) => SkillModel(
  id: id,
  name: id,
  kind: kind,
  category: category,
  level: level,
);

void main() {
  late _MockDatasource datasource;
  late SkillsRepositoryImpl repository;

  setUp(() {
    datasource = _MockDatasource();
    repository = SkillsRepositoryImpl(datasource);
  });

  test('getTechnologies returns only technology-kind skills', () async {
    when(() => datasource.getSkills()).thenAnswer(
      (_) async => <SkillModel>[
        _skill('flutter', kind: SkillKind.technology),
        _skill('clean-arch', kind: SkillKind.competency),
        _skill('dart', kind: SkillKind.technology),
      ],
    );

    final List<Skill> result = await repository.getTechnologies();

    expect(result.map((Skill s) => s.id), <String>['flutter', 'dart']);
  });

  test('getCompetenciesByCategory groups only competencies', () async {
    when(() => datasource.getSkills()).thenAnswer(
      (_) async => <SkillModel>[
        _skill('a', kind: SkillKind.competency, category: SkillCategory.mobile),
        _skill('b', kind: SkillKind.technology, category: SkillCategory.mobile),
        _skill(
          'c',
          kind: SkillKind.competency,
          category: SkillCategory.architecture,
        ),
      ],
    );

    final Map<SkillCategory, List<Skill>> grouped =
        await repository.getCompetenciesByCategory();

    expect(grouped.keys, <SkillCategory>[
      SkillCategory.mobile,
      SkillCategory.architecture,
    ]);
    // The technology in the mobile category must not leak into the group.
    expect(grouped[SkillCategory.mobile]!.map((Skill s) => s.id), <String>['a']);
  });

  test('grouping follows enum declaration order, not JSON order', () async {
    // Practices is declared last, so it must come last even though it is first
    // in the data — otherwise the section reshuffles when the file is edited.
    when(() => datasource.getSkills()).thenAnswer(
      (_) async => <SkillModel>[
        _skill(
          'practice',
          kind: SkillKind.competency,
          category: SkillCategory.practices,
        ),
        _skill(
          'mobile',
          kind: SkillKind.competency,
          category: SkillCategory.mobile,
        ),
      ],
    );

    final Map<SkillCategory, List<Skill>> grouped =
        await repository.getCompetenciesByCategory();

    expect(grouped.keys.first, SkillCategory.mobile);
    expect(grouped.keys.last, SkillCategory.practices);
  });

  test('empty categories are omitted rather than rendered blank', () async {
    when(() => datasource.getSkills()).thenAnswer(
      (_) async => <SkillModel>[
        _skill('a', kind: SkillKind.competency, category: SkillCategory.tools),
      ],
    );

    final Map<SkillCategory, List<Skill>> grouped =
        await repository.getCompetenciesByCategory();

    expect(grouped.length, 1);
    expect(grouped.containsKey(SkillCategory.backend), isFalse);
  });
}
