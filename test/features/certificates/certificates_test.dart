import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/core/domain/entities/localized_text.dart';
import 'package:portfolio/features/certificates/data/datasources/certificates_local_datasource.dart';
import 'package:portfolio/features/certificates/data/models/certificate_model.dart';
import 'package:portfolio/features/certificates/data/repositories/certificates_repository_impl.dart';
import 'package:portfolio/features/certificates/domain/entities/certificate.dart';

class _MockDatasource extends Mock implements CertificatesLocalDatasource {}

CertificateModel _model(String id, String issued) => CertificateModel(
  id: id,
  title: LocalizedText.same(id),
  issuer: const LocalizedText.same('issuer'),
  issueDate: DateTime.parse(issued),
);

void main() {
  group('Certificate', () {
    test('isExpired reflects a past expiry date', () {
      final Certificate expired = Certificate(
        id: 'a',
        title: const LocalizedText.empty(),
        issuer: const LocalizedText.empty(),
        issueDate: DateTime(2020),
        expiryDate: DateTime(2021),
      );
      expect(expired.isExpired, isTrue);
    });

    test('a null expiry never expires', () {
      final Certificate perpetual = Certificate(
        id: 'a',
        title: const LocalizedText.empty(),
        issuer: const LocalizedText.empty(),
        issueDate: DateTime(2020),
      );
      expect(perpetual.isExpired, isFalse);
    });

    test('isVerifiable requires a non-blank credential url', () {
      Certificate withUrl(String? url) => Certificate(
        id: 'a',
        title: const LocalizedText.empty(),
        issuer: const LocalizedText.empty(),
        issueDate: DateTime(2020),
        credentialUrl: url,
      );

      expect(withUrl('https://example.com').isVerifiable, isTrue);
      expect(withUrl(null).isVerifiable, isFalse);
      expect(withUrl('   ').isVerifiable, isFalse);
    });
  });

  group('CertificatesRepositoryImpl', () {
    late _MockDatasource datasource;
    late CertificatesRepositoryImpl repository;

    setUp(() {
      datasource = _MockDatasource();
      repository = CertificatesRepositoryImpl(datasource);
      when(() => datasource.getCertificates()).thenAnswer(
        (_) async => <CertificateModel>[
          _model('old', '2020-01-01'),
          _model('newest', '2024-01-01'),
          _model('mid', '2022-01-01'),
        ],
      );
    });

    test('sorts newest first', () async {
      final List<Certificate> result = await repository.getCertificates();
      expect(
        result.map((Certificate c) => c.id),
        <String>['newest', 'mid', 'old'],
      );
    });

    test('applies the limit after sorting, not before', () async {
      // Limiting before sorting would surface whichever entries happened to be
      // first in the file rather than the most recent ones.
      final List<Certificate> result = await repository.getCertificates(
        limit: 2,
      );
      expect(result.map((Certificate c) => c.id), <String>['newest', 'mid']);
    });
  });
}
