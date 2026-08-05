import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/utils/link_launcher.dart';
import '../../../../src/service_locator.dart';
import '../../domain/entities/certificate.dart';

/// One credential (PROJECT_SPEC §7.7).
class CertificateCard extends StatelessWidget {
  final Certificate certificate;

  const CertificateCard({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return CustomContainer(
      onTap: certificate.isVerifiable ? () => _verify(context) : null,
      color: colors.surface2,
      borderColor: colors.borderSubtle,
      borderRadius: BorderValues.b16.borderAll,
      padding: PaddingValues.p20.pAll,
      alignment: AlignmentDirectional.topStart,
      hoverLift: certificate.isVerifiable,
      semanticLabel: certificate.isVerifiable
          ? '${certificate.title.of(context)} — ${StringsManager.verifyCredential.tr(context)}'
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: AppSize.s32.rs,
                width: AppSize.s32.rs,
                child: CustomImage(
                  path: certificate.issuerLogoPath,
                  fit: BoxFit.contain,
                  monogram: certificate.issuer.of(context),
                  semanticLabel: certificate.issuer.of(context),
                ),
              ),
              const Spacer(),
              // [RULE] Status is never carried by colour alone — the expired
              // state is a text label, not just a tint (SPEC §14).
              if (certificate.isExpired)
                CustomText(
                  StringsManager.expired.tr(context),
                  fontSize: FontSize.labelMobile,
                  fontWeight: FontWeightManager.semiBold,
                  color: colors.warning,
                ),
            ],
          ),
          AppSize.s16.spaceH,
          CustomText.display(
            certificate.title.of(context),
            fontSize: FontSize.h3Desktop,
            height: LineHeights.heading,
            textAlign: TextAlign.start,
            maxLines: 2,
          ),
          AppSize.s6.spaceH,
          CustomText(
            certificate.issuer.of(context),
            fontSize: FontSize.captionDesktop,
            color: colors.textSecondary,
            textAlign: TextAlign.start,
            maxLines: 1,
          ),
          AppSize.s12.spaceH,
          CustomText(
            '${StringsManager.issued.tr(context)} ${_formatDate(certificate.issueDate)}',
            fontSize: FontSize.labelDesktop,
            color: colors.textTertiary,
            textAlign: TextAlign.start,
          ),
          if (certificate.credentialId != null) ...<Widget>[
            AppSize.s4.spaceH,
            CustomText(
              '${StringsManager.credentialId.tr(context)}: ${certificate.credentialId}',
              fontSize: FontSize.labelDesktop,
              color: colors.textTertiary,
              textAlign: TextAlign.start,
              maxLines: 1,
            ),
          ],
          if (certificate.isVerifiable) ...<Widget>[
            AppSize.s16.spaceH,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomText(
                  StringsManager.verifyCredential.tr(context),
                  fontSize: FontSize.labelDesktop,
                  fontWeight: FontWeightManager.semiBold,
                  color: colors.accent,
                ),
                AppSize.s4.spaceW,
                Icon(
                  IconsManager.externalLink,
                  size: AppSize.s12,
                  color: colors.accent,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _verify(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String failMsg = StringsManager.couldNotOpenLink.tr(context);

    final LaunchOutcome outcome = await sl<LinkLauncher>().open(
      certificate.credentialUrl!,
    );

    // [RULE] Guard BuildContext across the async gap (guide §22.6).
    if (outcome == LaunchOutcome.opened) return;
    messenger.showSnackBar(SnackBar(content: Text(failMsg)));
  }
}
