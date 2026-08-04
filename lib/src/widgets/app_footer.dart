import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/core.dart';
import '../../core/utils/link_launcher.dart';
import '../../features/contact/domain/entities/social_link.dart';
import '../../features/contact/domain/usecases/get_social_links_usecase.dart';
import '../../features/contact/presentation/cubit/contact_cubit.dart';
import '../service_locator.dart';
import 'max_width_wrapper.dart';

/// Social row, copyright, and the built-with line (PROJECT_SPEC §7.9).
///
/// [RULE] Footers do not animate — so this is NOT wrapped in a
/// SectionContainer, which exists to stage entrance motion (SPEC §7.9, §13).
///
/// It reads footer-flagged links through the same Contact slice rather than
/// owning data, keeping feature boundaries intact.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactCubit>(
      create: (_) =>
          sl<ContactCubit>()..getSocialLinks(params: GetSocialLinksParams.footer),
      child: Builder(builder: _build),
    );
  }

  Widget _build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isMobile = context.isMobile;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface0,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      padding: EdgeInsetsDirectional.symmetric(
        vertical: AppSize.s40.rh,
        horizontal: context
            .responsive(
              mobile: PaddingValues.screenPaddingMobile,
              desktop: PaddingValues.screenPaddingDesktop,
            )
            .rw,
      ),
      child: MaxWidthWrapper(
        child: Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomText(
                  StringsManager.appName.tr(context),
                  fontSize: FontSize.h3Desktop,
                  fontWeight: FontWeightManager.bold,
                  textAlign: TextAlign.start,
                ),
                AppSize.s6.spaceH,
                CustomText(
                  '© ${DateTime.now().year} · '
                  '${StringsManager.allRightsReserved.tr(context)}',
                  fontSize: FontSize.labelDesktop,
                  color: colors.textTertiary,
                  textAlign: TextAlign.start,
                ),
                AppSize.s4.spaceH,
                CustomText(
                  StringsManager.builtWithFlutter.tr(context),
                  fontSize: FontSize.labelDesktop,
                  color: colors.textTertiary,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            if (isMobile) AppSize.s24.spaceH else const Spacer(),
            BlocBuilder<ContactCubit, ContactState>(
              builder: (BuildContext context, ContactState state) {
                final List<SocialLink> links =
                    state.getSocialLinksState.data ?? const <SocialLink>[];
                // The footer degrades silently when links are unavailable: an
                // error card here would be noise at the bottom of the page.
                if (links.isEmpty) return const SizedBox.shrink();
                return Wrap(
                  spacing: AppSize.s8,
                  runSpacing: AppSize.s8,
                  children: <Widget>[
                    for (final SocialLink link in links)
                      _FooterIcon(link: link),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterIcon extends StatelessWidget {
  final SocialLink link;

  const _FooterIcon({required this.link});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Tooltip(
      message: link.label.of(context),
      child: CustomContainer(
        onTap: () => _open(context),
        shape: BoxShape.circle,
        color: colors.surface2,
        padding: PaddingValues.p12.pAll,
        // [RULE] Every icon-only button carries a semantic label (SPEC §14).
        semanticLabel: link.label.of(context),
        child: Icon(
          IconsManager.fromKey(link.iconKey),
          size: AppSize.s16,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String copiedMsg = StringsManager.couldNotOpenLink.tr(context);
    final LaunchOutcome outcome = await sl<LinkLauncher>().open(
      link.url,
      fallbackCopyValue: link.copyValue,
    );
    if (outcome == LaunchOutcome.opened) return;
    messenger.showSnackBar(SnackBar(content: Text(copiedMsg)));
  }
}
