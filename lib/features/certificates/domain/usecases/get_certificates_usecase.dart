import 'package:dartz/dartz.dart';

import '../../../../core/data/try_catch.dart';
import '../../../../core/domain/errors/failures.dart';
import '../../../../core/domain/usecases/base_usecase.dart';
import '../entities/certificate.dart';
import '../repositories/certificates_repository.dart';

class GetCertificatesUsecase
    extends BaseUseCase<List<Certificate>, GetCertificatesParams> {
  final CertificatesRepository _certificatesRepository;

  GetCertificatesUsecase(this._certificatesRepository);

  @override
  Future<Either<Failure, List<Certificate>>> call(
    GetCertificatesParams params,
  ) async {
    return tryCatch(
      tryFunction: () =>
          _certificatesRepository.getCertificates(limit: params.limit),
    );
  }
}

/// [RULE] The params class lives in the same file, below the use case
/// (guide §2.6).
class GetCertificatesParams {
  final int? limit;

  const GetCertificatesParams({this.limit});

  /// Home shows a preview; the dedicated screen shows everything.
  static const GetCertificatesParams preview = GetCertificatesParams(limit: 4);

  static const GetCertificatesParams all = GetCertificatesParams();
}
