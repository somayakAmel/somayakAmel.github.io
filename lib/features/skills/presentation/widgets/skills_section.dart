import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../src/service_locator.dart';
import '../../../../src/widgets/section_container.dart';
import '../../../../src/widgets/section_header.dart';
import '../../../../src/widgets/section_state_builder.dart';
import '../../domain/entities/skill.dart';
import '../../domain/usecases/get_skills_usecase.dart';
import '../cubit/skills_cubit.dart';
import 'skill_level_bar.dart';

/// The Skills block on Home (PROJECT_SPEC §7.4).
///
/// Renders COMPETENCIES grouped by category, with a coarse proficiency signal.
/// Technologies are a separate section — see [TechStackSection].
class SkillsSection extends StatelessWidget {
  final GlobalKey? anchorKey;

  const SkillsSection({super.key, this.anchorKey});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SkillsCubit>(
      create: (_) => sl<SkillsCubit>()..getSkills(),
      child: Builder(
        builder: (BuildContext context) => SectionContainer(
          sectionId: 'skills',
          anchorKey: anchorKey,
          background: context.colors.surface1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionHeader(
                eyebrowKey: StringsManager.skillsEyebrow,
                titleKey: StringsManager.skillsTitle,
              ),
              AppSize.s32.spaceH,
              BlocBuilder<SkillsCubit, SkillsState>(
                builder: (BuildContext context, SkillsState state) =>
                    SectionStateBuilder<SkillsBundle>(
                      state: state.getSkillsState,
                      isEmpty: (SkillsBundle b) => b.competencies.isEmpty,
                      empty: SectionEmptyState(
                        title: StringsManager.noSkills.tr(context),
                      ),
                      onRetry: () => SkillsCubit.get(context).getSkills(),
                      builder: (BuildContext context, SkillsBundle bundle) =>
                          _CompetencyGrid(grouped: bundle.competencies),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompetencyGrid extends StatelessWidget {
  final Map<SkillCategory, List<Skill>> grouped;

  const _CompetencyGrid({required this.grouped});

  @override
  Widget build(BuildContext context) {
    final List<Widget> groups = <Widget>[
      for (final MapEntry<SkillCategory, List<Skill>> entry in grouped.entries)
        _CategoryGroup(category: entry.key, skills: entry.value),
    ];

    // Desktop: 2-column category grid. Mobile: single column (SPEC §12).
    if (!context.isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < groups.length; i++) ...<Widget>[
            if (i > 0) AppSize.s32.spaceH,
            groups[i],
          ],
        ],
      );
    }

    return Wrap(
      spacing: AppSize.s48,
      runSpacing: AppSize.s32,
      children: <Widget>[
        for (final Widget group in groups)
          // Two columns, accounting for the inter-column spacing.
          SizedBox(width: (AppSize.maxContentWidth - AppSize.s48) / 2, child: group),
      ],
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  final SkillCategory category;
  final List<Skill> skills;

  const _CategoryGroup({required this.category, required this.skills});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CustomText(
          category.labelKey.tr(context).toUpperCase(),
          fontSize: FontSize.labelDesktop,
          fontWeight: FontWeightManager.semiBold,
          color: colors.accent,
          letterSpacing: 1.2,
          textAlign: TextAlign.start,
        ),
        AppSize.s16.spaceH,
        for (final Skill skill in skills)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: AppSize.s12.rh),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CustomText(
                    skill.name,
                    fontSize: FontSize.bodyDesktop,
                    color: colors.textSecondary,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                ),
                if (skill.level != null) ...<Widget>[
                  AppSize.s12.spaceW,
                  SkillLevelBar(level: skill.level!),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
