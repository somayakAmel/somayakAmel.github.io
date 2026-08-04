import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/custom_state.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/usecases/get_certificates_usecase.dart';

part 'certificates_state.dart';

class CertificatesCubit extends Cubit<CertificatesState> {
  final GetCertificatesUsecase _getCertificatesUsecase;

  CertificatesCubit(this._getCertificatesUsecase)
    : super(const CertificatesState());

  static CertificatesCubit get(BuildContext context) =>
      BlocProvider.of(context);

  Future<void> getCertificates({
    GetCertificatesParams params = GetCertificatesParams.all,
  }) async {
    emit(
      state.copyWith(
        getCertificatesState: const CustomState<List<Certificate>>.loading(),
      ),
    );

    final result = await _getCertificatesUsecase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          getCertificatesState: CustomState<List<Certificate>>.failure(
            failure.message ?? 'Unknown error',
          ),
        ),
      ),
      (items) => emit(
        state.copyWith(
          getCertificatesState: CustomState<List<Certificate>>.success(items),
        ),
      ),
    );
  }
}
