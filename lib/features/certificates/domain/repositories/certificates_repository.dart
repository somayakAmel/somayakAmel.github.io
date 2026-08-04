import '../entities/certificate.dart';

abstract class CertificatesRepository {
  /// Credentials, newest first, capped at [limit] when given.
  Future<List<Certificate>> getCertificates({int? limit});
}
