part of 'certificates_cubit.dart';

class CertificatesState extends Equatable {
  final CustomState<List<Certificate>> getCertificatesState;

  const CertificatesState({
    this.getCertificatesState = const CustomState<List<Certificate>>.initial(),
  });

  CertificatesState copyWith({
    CustomState<List<Certificate>>? getCertificatesState,
  }) => CertificatesState(
    getCertificatesState: getCertificatesState ?? this.getCertificatesState,
  );

  @override
  List<Object?> get props => <Object?>[getCertificatesState];
}
