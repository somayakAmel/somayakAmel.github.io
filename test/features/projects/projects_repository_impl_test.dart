import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/core/domain/entities/localized_text.dart';
import 'package:portfolio/core/domain/errors/exceptions.dart';
import 'package:portfolio/features/projects/data/datasources/projects_local_datasource.dart';
import 'package:portfolio/features/projects/data/models/project_detail_model.dart';
import 'package:portfolio/features/projects/data/models/project_summary_model.dart';
import 'package:portfolio/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:portfolio/features/projects/domain/entities/project_detail.dart';
import 'package:portfolio/features/projects/domain/entities/project_summary.dart';

class _MockDatasource extends Mock implements ProjectsLocalDatasource {}

ProjectSummaryModel _summary(
  String slug, {
  bool featured = false,
  int order = 0,
  ProjectType type = ProjectType.client,
}) => ProjectSummaryModel(
  slug: slug,
  title: LocalizedText.same(slug),
  tagline: const LocalizedText.empty(),
  domain: const LocalizedText.empty(),
  type: type,
  detailFile: 'assets/data/projects/$slug.json',
  isFeatured: featured,
  order: order,
);

ProjectDetailModel _detail(String slug) => ProjectDetailModel(
  slug: slug,
  overview: const LocalizedText.empty(),
  role: const LocalizedText.empty(),
  duration: const LocalizedText.empty(),
  status: ProjectStatus.live,
);

void main() {
  late _MockDatasource datasource;
  late ProjectsRepositoryImpl repository;

  setUp(() {
    datasource = _MockDatasource();
    repository = ProjectsRepositoryImpl(datasource);
  });

  group('getFeaturedProjects', () {
    test('returns only featured projects, capped at the limit', () async {
      when(() => datasource.getProjectIndex()).thenAnswer(
        (_) async => <ProjectSummaryModel>[
          _summary('a', featured: true),
          _summary('b', featured: false),
          _summary('c', featured: true),
          _summary('d', featured: true),
        ],
      );

      final List<ProjectSummary> result = await repository.getFeaturedProjects(
        limit: 2,
      );

      expect(result.length, 2);
      expect(result.map((ProjectSummary p) => p.slug), <String>['a', 'c']);
    });

    test('returns all featured when no limit is given', () async {
      when(() => datasource.getProjectIndex()).thenAnswer(
        (_) async => <ProjectSummaryModel>[
          _summary('a', featured: true),
          _summary('b', featured: true),
        ],
      );

      expect((await repository.getFeaturedProjects()).length, 2);
    });
  });

  group('getProjectDetail', () {
    test('composes the summary and detail into one entity', () async {
      when(() => datasource.getProjectIndex()).thenAnswer(
        (_) async => <ProjectSummaryModel>[_summary('motary')],
      );
      when(
        () => datasource.getProjectDetail(any()),
      ).thenAnswer((_) async => _detail('motary'));

      final ProjectDetail detail = await repository.getProjectDetail('motary');

      expect(detail.slug, 'motary');
      expect(detail.summary.slug, 'motary');
    });

    test('throws NotFoundException for a slug absent from the index', () async {
      when(
        () => datasource.getProjectIndex(),
      ).thenAnswer((_) async => <ProjectSummaryModel>[_summary('motary')]);

      expect(
        () => repository.getProjectDetail('ghost'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('throws when the detail file declares a different slug', () async {
      // Catches a mis-wired detail_file immediately, rather than silently
      // rendering the wrong project (PROJECT_SPEC §9).
      when(
        () => datasource.getProjectIndex(),
      ).thenAnswer((_) async => <ProjectSummaryModel>[_summary('motary')]);
      when(
        () => datasource.getProjectDetail(any()),
      ).thenAnswer((_) async => _detail('qanony'));

      expect(
        () => repository.getProjectDetail('motary'),
        throwsA(isA<ProjectSlugMismatchException>()),
      );
    });
  });
}
