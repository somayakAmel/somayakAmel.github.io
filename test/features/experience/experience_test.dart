import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/core/domain/entities/localized_text.dart';
import 'package:portfolio/features/experience/data/datasources/experience_local_datasource.dart';
import 'package:portfolio/features/experience/data/models/experience_model.dart';
import 'package:portfolio/features/experience/data/repositories/experience_repository_impl.dart';
import 'package:portfolio/features/experience/domain/entities/experience.dart';

class _MockDatasource extends Mock implements ExperienceLocalDatasource {}

ExperienceModel _model(String id, String start, String? end) => ExperienceModel(
  id: id,
  company: LocalizedText.same(id),
  role: const LocalizedText.same('role'),
  employmentType: EmploymentType.fullTime,
  startDate: DateTime.parse(start),
  endDate: end == null ? null : DateTime.parse(end),
  location: const LocalizedText.empty(),
);

void main() {
  group('ExperienceModel.fromJson', () {
    test('parses a full entry', () {
      final ExperienceModel model = ExperienceModel.fromJson(
        <String, dynamic>{
          'id': 'role-1',
          'company': <String, dynamic>{'en': 'Acme', 'ar': 'أكمي'},
          'role': <String, dynamic>{'en': 'Dev', 'ar': 'مطور'},
          'employment_type': 'freelance',
          'start_date': '2024-03-01',
          'end_date': null,
          'achievements': <dynamic>[
            <String, dynamic>{'en': 'Shipped', 'ar': 'أطلقت'},
          ],
          'technologies': <dynamic>['Flutter'],
        },
      );

      expect(model.id, 'role-1');
      expect(model.employmentType, EmploymentType.freelance);
      expect(model.endDate, isNull);
      expect(model.achievements.single.en, 'Shipped');
      expect(model.technologies, <String>['Flutter']);
    });

    test('unknown employment_type falls back instead of throwing', () {
      final ExperienceModel model = ExperienceModel.fromJson(
        <String, dynamic>{'id': 'x', 'employment_type': 'bogus'},
      );
      expect(model.employmentType, EmploymentType.fullTime);
    });

    test('a missing start_date does not throw', () {
      // A malformed date must degrade one card, not crash the section.
      final ExperienceModel model = ExperienceModel.fromJson(
        <String, dynamic>{'id': 'x'},
      );
      expect(model.startDate, DateTime(1970));
    });
  });

  group('Experience duration', () {
    test('isCurrent is true when endDate is null', () {
      final Experience e = _model('a', '2024-01-01', null).toEntity();
      expect(e.isCurrent, isTrue);
    });

    test('durationMonths counts whole months', () {
      final Experience e = _model('a', '2022-01-01', '2023-07-01').toEntity();
      expect(e.durationMonths, 18);
      expect(e.durationYearsPart, 1);
      expect(e.durationMonthsPart, 6);
    });

    test('a same-month role still counts as one month', () {
      // Avoids rendering "0 mo", which reads as a data bug to a reviewer.
      final Experience e = _model('a', '2024-03-01', '2024-03-20').toEntity();
      expect(e.durationMonths, 1);
    });
  });

  group('ExperienceRepositoryImpl', () {
    test('sorts newest first regardless of JSON order', () async {
      final _MockDatasource datasource = _MockDatasource();
      when(() => datasource.getExperience()).thenAnswer(
        (_) async => <ExperienceModel>[
          _model('old', '2019-01-01', '2020-01-01'),
          _model('new', '2024-01-01', null),
          _model('mid', '2021-01-01', '2023-01-01'),
        ],
      );

      final List<Experience> result = await ExperienceRepositoryImpl(
        datasource,
      ).getExperience();

      expect(
        result.map((Experience e) => e.company.en),
        <String>['new', 'mid', 'old'],
      );
    });
  });
}
