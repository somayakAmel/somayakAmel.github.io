import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../src/service_locator.dart';
import '../../../../src/widgets/section_container.dart';
import '../../../../src/widgets/section_header.dart';
import '../../../../src/widgets/section_state_builder.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/usecases/get_certificates_usecase.dart';
import '../cubit/certificates_cubit.dart';
import '../screens/certificates_screen.dart';
import 'certificate_card.dart';

/// The Certifications block on Home (PROJECT_SPEC §7.7).
///
/// Shows a preview capped at four; the full list lives on /certificates.
class CertificatesSection extends StatelessWidget {
  final GlobalKey? anchorKey;

  const CertificatesSection({super.key, this.anchorKey});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CertificatesCubit>(
      create: (_) => sl<CertificatesCubit>()
        ..getCertificates(params: GetCertificatesParams.preview),
      child: Builder(
        builder: (BuildContext context) => SectionContainer(
          sectionId: 'certificates',
          anchorKey: anchorKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionHeader(
                eyebrowKey: StringsManager.certificatesEyebrow,
                titleKey: StringsManager.certificatesTitle,
                actionKey: StringsManager.viewAll,
                onActionTap: () =>
                    Navigator.of(context).pushNamed(CertificatesScreen.route),
              ),
              AppSize.s32.spaceH,
              BlocBuilder<CertificatesCubit, CertificatesState>(
                builder: (BuildContext context, CertificatesState state) =>
                    SectionStateBuilder<List<Certificate>>(
                      state: state.getCertificatesState,
                      isEmpty: (List<Certificate> c) => c.isEmpty,
                      empty: SectionEmptyState(
                        title: StringsManager.noCertificates.tr(context),
                      ),
                      onRetry: () => CertificatesCubit.get(context)
                          .getCertificates(
                            params: GetCertificatesParams.preview,
                          ),
                      builder:
                          (BuildContext context, List<Certificate> items) =>
                              CertificatesGrid(certificates: items),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Responsive credential grid, shared by the Home section and /certificates
/// (PROJECT_SPEC §12): 4-col desktop, 2-col tablet, 1-col mobile.
class CertificatesGrid extends StatelessWidget {
  final List<Certificate> certificates;

  const CertificatesGrid({super.key, required this.certificates});

  @override
  Widget build(BuildContext context) {
    final int columns = context.responsive(mobile: 1, tablet: 2, desktop: 4);

    // A Wrap rather than a GridView: a fixed childAspectRatio forces every card
    // to one height, which left a large empty gap under cards that have no
    // credential id or verify link. Wrap lets each card be as tall as its
    // content, and rows still align because the tallest card sets the run
    // height.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = AppSize.s16;
        final double itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final Certificate certificate in certificates)
              SizedBox(
                width: itemWidth,
                child: CertificateCard(certificate: certificate),
              ),
          ],
        );
      },
    );
  }
}
