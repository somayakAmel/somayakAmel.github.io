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
import 'skill_category_card.dart';

/// The Skills block on Home (PROJECT_SPEC §7.4, redesigned per the design
/// brief).
///
/// ## What changed and why
///
/// The previous version rendered competencies as a two-column list of plain
/// text with a proficiency bar, and pushed technologies into a separate
/// "Tech Stack" section further down. That had three problems the brief names:
/// it scanned like documentation, it wasted vertical space on a long thin
/// column, and splitting one dataset across two sections made the page repeat
/// itself.
///
/// This version merges both kinds into ONE responsive card grid keyed by
/// category, so a reader sees "Mobile: Flutter, Dart, Java…" as a single
/// coherent group rather than meeting the same subject twice. [TechStackSection]
/// is retired as a result.
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
                      isEmpty: (SkillsBundle b) => b.isEmpty,
                      empty: SectionEmptyState(
                        title: StringsManager.noSkills.tr(context),
                      ),
                      onRetry: () => SkillsCubit.get(context).getSkills(),
                      builder: (BuildContext context, SkillsBundle bundle) =>
                          _SkillsGrid(bundle: bundle),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillsGrid extends StatelessWidget {
  final SkillsBundle bundle;

  const _SkillsGrid({required this.bundle});

  /// Competencies and technologies merged, grouped by category in enum
  /// declaration order so the grid never reshuffles when the JSON is edited.
  Map<SkillCategory, List<Skill>> get _grouped {
    final List<Skill> all = <Skill>[
      ...bundle.competencies.values.expand((List<Skill> s) => s),
      ...bundle.technologies,
    ];

    final Map<SkillCategory, List<Skill>> grouped =
        <SkillCategory, List<Skill>>{};
    for (final SkillCategory category in SkillCategory.values) {
      final List<Skill> inCategory =
          all.where((Skill s) => s.category == category).toList()
            // Core first inside each card, so the strongest signal is the
            // first thing read in every group.
            ..sort((Skill a, Skill b) {
              if (a.isCore != b.isCore) return a.isCore ? -1 : 1;
              return 0;
            });
      if (inCategory.isNotEmpty) grouped[category] = inCategory;
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final Map<SkillCategory, List<Skill>> grouped = _grouped;
    final List<SkillCategory> categories = grouped.keys.toList();

    // 3 columns on large desktop, 2 on desktop/tablet, 1 on mobile — the
    // brief's §3, and what removes the tall empty column the old layout left.
    final int columns = context.responsive(
      mobile: 1,
      tablet: 2,
      desktop: 2,
      largeDesktop: 3,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = AppSize.s16;
        final double itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Wrap rather than a GridView: a fixed aspect ratio would force
            // every card to the height of the tallest, leaving dead space
            // under the short ones. Wrap lets each card size to its chips
            // while rows still align on the tallest in that run.
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                for (int i = 0; i < categories.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: _Staggered(
                      index: i,
                      child: SkillCategoryCard(
                        category: categories[i],
                        skills: grouped[categories[i]]!,
                      ),
                    ),
                  ),
              ],
            ),
            AppSize.s32.spaceH,
            Row(
              children: <Widget>[
                Icon(
                  IconsManager.sparkle,
                  size: AppSize.s14,
                  color: context.colors.textTertiary,
                ),
                AppSize.s8.spaceW,
                Flexible(
                  child: CustomText(
                    StringsManager.skillsFooter.tr(context),
                    fontSize: FontSize.captionDesktop,
                    color: context.colors.textTertiary,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Fades and lifts a card in, offset by its position in the grid
/// (design brief §6).
///
/// The delay is capped so a long grid does not leave the last card visibly
/// waiting — past roughly half a second the stagger stops reading as rhythm
/// and starts reading as lag.
class _Staggered extends StatefulWidget {
  final int index;
  final Widget child;

  const _Staggered({required this.index, required this.child});

  @override
  State<_Staggered> createState() => _StaggeredState();
}

class _StaggeredState extends State<_Staggered> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    final int delay = (widget.index * DurationValues.staggerStep)
        .clamp(0, 480)
        .toInt();
    Future<void>.delayed(Duration(milliseconds: delay), () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;

    return AnimatedSlide(
      offset: _shown ? Offset.zero : const Offset(0, 0.06),
      duration: DurationValues.dm400.milliseconds,
      curve: AppCurves.entrance,
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: DurationValues.dm400.milliseconds,
        curve: AppCurves.entrance,
        child: widget.child,
      ),
    );
  }
}
