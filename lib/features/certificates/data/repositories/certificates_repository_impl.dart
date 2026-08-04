import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificates_repository.dart';
import '../datasources/certificates_local_datasource.dart';
import '../models/certificate_model.dart';

class CertificatesRepositoryImpl implements CertificatesRepository {
  final CertificatesLocalDatasource _localDatasource;

  CertificatesRepositoryImpl(this._localDatasource);

  @override
  Future<List<Certificate>> getCertificates({int? limit}) async {
    final List<CertificateModel> models = await _localDatasource
        .getCertificates();

    final List<Certificate> entities = models
        .map((CertificateModel e) => e.toEntity())
        .toList();

    // Newest first.
    entities.sort(
      (Certificate a, Certificate b) => b.issueDate.compareTo(a.issueDate),
    );

    if (limit != null && entities.length > limit) {
      return entities.sublist(0, limit);
    }
    return entities;
  }
}
