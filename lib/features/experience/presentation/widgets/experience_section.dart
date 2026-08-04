import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../src/service_locator.dart';
import '../../../../src/widgets/section_container.dart';
import '../../../../src/widgets/section_header.dart';
import '../../../../src/widgets/section_state_builder.dart';
import '../../../../src/widgets/tag_chip.dart';
import '../../domain/entities/experience.dart';
import '../cubit/experience_cubit.dart';

/// The Experience block on Home (PROJECT_SPEC §7.6).
///
/// A start-anchored vertical timeline at every breakpoint. The spec sketched an
/// alternating centred spine for desktop; a single anchored spine is used
/// instead because alternating sides forces the reader's eye to zig-zag and
/// breaks down entirely in RTL, where the "sides" invert. Same information,
/// less visual cost.
class ExperienceSection extends StatelessWidget {
  final GlobalKey? anchorKey;

  const ExperienceSection({super.key, this.anchorKey});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExperienceCubit>(
      create: (_) => sl<ExperienceCubit>()..getExperience(),
      child: Builder(
        builder: (BuildContext context) => SectionContainer(
          sectionId: 'experience',
          anchorKey: anchorKey,
          background: context.colors.surface1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionHeader(
                eyebrowKey: StringsManager.experienceEyebrow,
                titleKey: StringsManager.experienceTitle,
              ),
              AppSize.s32.spaceH,
              BlocBuilder<ExperienceCubit, ExperienceState>(
                builder: (BuildContext context, ExperienceState state) =>
                    SectionStateBuilder<List<Experience>>(
                      state: state.getExperienceState,
                      isEmpty: (List<Experience> e) => e.isEmpty,
                      empty: SectionEmptyState(
                        title: StringsManager.noExperience.tr(context),
                      ),
                      onRetry: () =>
                          ExperienceCubit.get(context).getExperience(),
                      builder:
                          (BuildContext context, List<Experience> items) =>
                              _Timeline(items: items),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<Experience> items;

  const _Timeline({required this.items});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      for (int i = 0; i < items.length; i++)
        _TimelineEntry(
          experience: items[i],
          isLast: i == items.length - 1,
        ),
    ],
  );
}

class _TimelineEntry extends StatelessWidget {
  final Experience experience;
  final bool isLast;

  const _TimelineEntry({required this.experience, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isMobile = context.isMobile;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // The spine. Uses a Row so it sits at the start edge, which
          // Directionality mirrors correctly for Arabic.
          SizedBox(
            width: AppSize.s24.rw,
            child: Column(
              children: <Widget>[
                Container(
                  width: AppSize.s12,
                  height: AppSize.s12,
                  margin: EdgeInsetsDirectional.only(top: AppSize.s6.rh),
                  decoration: BoxDecoration(
                    color: experience.isCurrent
                        ? colors.accent
                        : colors.surface3,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: experience.isCurrent
                          ? colors.accent
                          : colors.borderStrong,
                      width: AppSize.s2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: AppSize.s2,
                      margin: EdgeInsetsDirectional.only(top: AppSize.s4.rh),
                      color: colors.borderSubtle,
                    ),
                  ),
              ],
            ),
          ),
          AppSize.s16.spaceW,
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: isLast ? 0 : AppSize.s32.rh,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (experience.logoPath != null) ...<Widget>[
                        SizedBox(
                          height: AppSize.s32.rs,
                          width: AppSize.s32.rs,
                          child: CustomImage(
                            path: experience.logoPath,
                            fit: BoxFit.contain,
                            monogram: experience.company.of(context),
                            semanticLabel: experience.company.of(context),
                          ),
                        ),
                        AppSize.s12.spaceW,
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CustomText(
                              experience.role.of(context),
                              fontSize: isMobile
                                  ? FontSize.h3Mobile
                                  : FontSize.h3Desktop,
                              fontWeight: FontWeightManager.bold,
                              textAlign: TextAlign.start,
                            ),
                            AppSize.s4.spaceH,
                            CustomText(
                              experience.company.of(context),
                              fontSize: FontSize.captionDesktop,
                              fontWeight: FontWeightManager.medium,
                              color: colors.accent,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSize.s8.spaceH,
                  _MetaLine(experience: experience),
                  if (experience.achievements.isNotEmpty) ...<Widget>[
                    AppSize.s12.spaceH,
                    for (final LocalizedText achievement
                        in experience.achievements)
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          bottom: AppSize.s6.rh,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsetsDirectional.only(
                                top: AppSize.s8.rh,
                                end: AppSize.s8.rw,
                              ),
                              child: Container(
                                height: AppSize.s4,
                                width: AppSize.s4,
                                decoration: BoxDecoration(
                                  color: colors.textTertiary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Expanded(
                              child: CustomText(
                                achievement.of(context),
                                fontSize: FontSize.captionDesktop,
                                color: colors.textSecondary,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  if (experience.technologies.isNotEmpty) ...<Widget>[
                    AppSize.s12.spaceH,
                    Wrap(
                      spacing: AppSize.s6,
                      runSpacing: AppSize.s6,
                      children: <Widget>[
                        for (final String tech in experience.technologies)
                          TagChip(tech, dense: true),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Date range · duration · type · location, on one wrapping line.
class _MetaLine extends StatelessWidget {
  final Experience experience;

  const _MetaLine({required this.experience});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    final String range =
        '${_year(experience.startDate)} — '
        '${experience.isCurrent ? StringsManager.present.tr(context) : _year(experience.endDate!)}';

    final String duration = _duration(context);

    return Wrap(
      spacing: AppSize.s8,
      runSpacing: AppSize.s4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _chip(context, range),
        _dot(colors),
        _chip(context, duration),
        _dot(colors),
        _chip(context, experience.employmentType.labelKey.tr(context)),
        if (experience.location.isNotEmpty) ...<Widget>[
          _dot(colors),
          _chip(context, experience.location.of(context)),
        ],
      ],
    );
  }

  String _year(DateTime date) => '${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _duration(BuildContext context) {
    final int years = experience.durationYearsPart;
    final int months = experience.durationMonthsPart;
    final String y = StringsManager.durationYears.tr(context);
    final String m = StringsManager.durationMonths.tr(context);
    if (years == 0) return '$months $m';
    if (months == 0) return '$years $y';
    return '$years $y $months $m';
  }

  Widget _chip(BuildContext context, String text) => CustomText(
    text,
    fontSize: FontSize.labelDesktop,
    color: context.colors.textTertiary,
    textAlign: TextAlign.start,
  );

  Widget _dot(AppColorScheme colors) => Container(
    height: AppSize.s2,
    width: AppSize.s2,
    decoration: BoxDecoration(color: colors.textTertiary, shape: BoxShape.circle),
  );
}
