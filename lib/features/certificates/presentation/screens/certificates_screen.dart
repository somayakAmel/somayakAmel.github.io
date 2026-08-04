import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../src/service_locator.dart';
import '../../../../src/widgets/max_width_wrapper.dart';
import '../../../../src/widgets/section_state_builder.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/usecases/get_certificates_usecase.dart';
import '../cubit/certificates_cubit.dart';
import '../widgets/certificates_section.dart';

/// All credentials (PROJECT_SPEC §6, S5).
class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  static const String route = '/certificates';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CertificatesCubit>(
      create: (_) => sl<CertificatesCubit>()
        ..getCertificates(params: GetCertificatesParams.all),
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: CustomAppBar(
            title: StringsManager.allCertificates.tr(context),
            isScrolled: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(
              top: AppSize.s24.rh,
              bottom: AppSize.s64.rh,
            ),
            child: MaxWidthWrapper(
              child: BlocBuilder<CertificatesCubit, CertificatesState>(
                builder: (BuildContext context, CertificatesState state) =>
                    SectionStateBuilder<List<Certificate>>(
                      state: state.getCertificatesState,
                      isEmpty: (List<Certificate> c) => c.isEmpty,
                      empty: SectionEmptyState(
                        title: StringsManager.noCertificates.tr(context),
                      ),
                      onRetry: () => CertificatesCubit.get(
                        context,
                      ).getCertificates(params: GetCertificatesParams.all),
                      builder:
                          (BuildContext context, List<Certificate> items) =>
                              CertificatesGrid(certificates: items),
                    ).withPadding(
                      context
                          .responsive(
                            mobile: PaddingValues.screenPaddingMobile,
                            desktop: PaddingValues.screenPaddingDesktop,
                          )
                          .pSymmetricH,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
