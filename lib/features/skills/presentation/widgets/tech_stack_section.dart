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

/// The Tech Stack block on Home (PROJECT_SPEC §7.5).
///
/// Renders TECHNOLOGIES as a dense tile grid: logo plus name, no proficiency,
/// no category headers. The counterpart to [SkillsSection], which handles
/// competencies — the two are distinguished by `kind` in skills.json (SPEC §4).
///
/// Provides its own cubit instance rather than sharing the Skills section's:
/// both resolve to the same memoized asset read, so there is no double parse.
class TechStackSection extends StatelessWidget {
  const TechStackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SkillsCubit>(
      create: (_) => sl<SkillsCubit>()..getSkills(),
      child: Builder(
        builder: (BuildContext context) => SectionContainer(
          sectionId: 'tech-stack',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionHeader(
                eyebrowKey: StringsManager.skillsCompetencies,
                titleKey: StringsManager.techStackTitle,
              ),
              AppSize.s32.spaceH,
              BlocBuilder<SkillsCubit, SkillsState>(
                builder: (BuildContext context, SkillsState state) =>
                    SectionStateBuilder<SkillsBundle>(
                      state: state.getSkillsState,
                      isEmpty: (SkillsBundle b) => b.technologies.isEmpty,
                      empty: SectionEmptyState(
                        title: StringsManager.noSkills.tr(context),
                      ),
                      onRetry: () => SkillsCubit.get(context).getSkills(),
                      builder: (BuildContext context, SkillsBundle bundle) =>
                          _TechGrid(technologies: bundle.technologies),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TechGrid extends StatelessWidget {
  final List<Skill> technologies;

  const _TechGrid({required this.technologies});

  @override
  Widget build(BuildContext context) => SizedBox(
    // Full width so the Wrap starts at the section's start edge like every
    // other section, rather than shrink-wrapping and centring itself — which
    // broke the page's alignment rhythm.
    width: double.infinity,
    child: Wrap(
      spacing: AppSize.s12,
      runSpacing: AppSize.s12,
      children: <Widget>[
        for (final Skill tech in technologies) _TechTile(skill: tech),
      ],
    ),
  );
}

class _TechTile extends StatefulWidget {
  final Skill skill;

  const _TechTile({required this.skill});

  @override
  State<_TechTile> createState() => _TechTileState();
}

class _TechTileState extends State<_TechTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: context.reduceMotion
            ? Duration.zero
            : DurationValues.dm150.milliseconds,
        curve: AppCurves.state,
        width: AppSize.s120.rw,
        padding: PaddingValues.p16.pAll,
        decoration: BoxDecoration(
          color: _isHovered ? colors.surface3 : colors.surface2,
          border: Border.all(
            color: _isHovered ? colors.accent : colors.borderSubtle,
          ),
          borderRadius: BorderRadius.circular(BorderValues.b12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: AppSize.s32.rs,
              width: AppSize.s32.rs,
              // A missing logo degrades to a monogram tile — the grid must
              // never show a broken-image box (SPEC §7.5).
              child: CustomImage(
                path: widget.skill.logoPath,
                fit: BoxFit.contain,
                monogram: widget.skill.name,
                semanticLabel: widget.skill.name,
              ),
            ),
            AppSize.s12.spaceH,
            CustomText(
              widget.skill.name,
              fontSize: FontSize.labelDesktop,
              fontWeight: FontWeightManager.medium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
              maxLines: 2,
              height: LineHeights.tight,
            ),
          ],
        ),
      ),
    );
  }
}
