import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../src/service_locator.dart';
import '../../../../src/widgets/link_button.dart';
import '../../../../src/widgets/section_container.dart';
import '../../../../src/widgets/section_header.dart';
import '../../../../src/widgets/section_state_builder.dart';
import '../../../../src/widgets/max_width_wrapper.dart';
import '../../domain/entities/social_link.dart';
import '../cubit/contact_cubit.dart';

/// The Contact block on Home (PROJECT_SPEC §7.8).
///
/// Deliberately has NO contact form: a form needs a backend, which the brief
/// forbids, and a form that silently does nothing is worse than none. Every
/// action here is a real link with a clipboard fallback.
class ContactSection extends StatelessWidget {
  final GlobalKey? anchorKey;

  const ContactSection({super.key, this.anchorKey});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactCubit>(
      create: (_) => sl<ContactCubit>()..getSocialLinks(),
      child: Builder(
        builder: (BuildContext context) => SectionContainer(
          sectionId: 'contact',
          anchorKey: anchorKey,
          background: context.colors.surface1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionHeader(
                eyebrowKey: StringsManager.contactEyebrow,
                titleKey: StringsManager.contactTitle,
              ),
              AppSize.s16.spaceH,
              ProseWidth(
                child: CustomText(
                  StringsManager.contactAvailability.tr(context),
                  fontSize: context.isMobile
                      ? FontSize.bodyMobile
                      : FontSize.bodyLargeDesktop,
                  color: context.colors.textSecondary,
                  textAlign: TextAlign.start,
                ),
              ),
              AppSize.s32.spaceH,
              BlocBuilder<ContactCubit, ContactState>(
                builder: (BuildContext context, ContactState state) =>
                    SectionStateBuilder<List<SocialLink>>(
                      state: state.getSocialLinksState,
                      isEmpty: (List<SocialLink> l) => l.isEmpty,
                      empty: SectionEmptyState(
                        title: StringsManager.noContactLinks.tr(context),
                      ),
                      onRetry: () => ContactCubit.get(context).getSocialLinks(),
                      builder:
                          (BuildContext context, List<SocialLink> links) =>
                              _ContactActions(links: links),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactActions extends StatelessWidget {
  final List<SocialLink> links;

  const _ContactActions({required this.links});

  @override
  Widget build(BuildContext context) {
    // Email is the primary CTA when present; everything else is secondary.
    final SocialLink? primary = links
        .where((SocialLink l) => l.platform == SocialPlatform.email)
        .firstOrNull;

    final List<SocialLink> secondary = links
        .where((SocialLink l) => l != primary)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (primary != null) ...<Widget>[
          LinkButton(
            url: primary.url,
            label: primary.label.of(context),
            copyValue: primary.copyValue,
            icon: IconsManager.fromKey(primary.iconKey),
            isFilled: true,
          ),
          AppSize.s16.spaceH,
        ],
        Wrap(
          spacing: AppSize.s12,
          runSpacing: AppSize.s12,
          children: <Widget>[
            for (final SocialLink link in secondary)
              LinkButton(
                url: link.url,
                label: link.label.of(context),
                copyValue: link.copyValue,
                icon: IconsManager.fromKey(link.iconKey),
              ),
          ],
        ),
      ],
    );
  }
}
