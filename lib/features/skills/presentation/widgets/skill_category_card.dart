import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entities/skill.dart';
import 'skill_chip.dart';

/// One skill category as a card: icon, title, description, chip grid
/// (design brief §2 and §4).
///
/// The card is the unit that fixes the old layout's problems — a bare list of
/// category headings gave the eye nothing to land on, so the section scanned
/// like documentation. A bounded surface with a leading glyph gives each group
/// a shape, and the chips inside give the content texture.
class SkillCategoryCard extends StatefulWidget {
  final SkillCategory category;
  final List<Skill> skills;

  const SkillCategoryCard({
    super.key,
    required this.category,
    required this.skills,
  });

  @override
  State<SkillCategoryCard> createState() => _SkillCategoryCardState();
}

class _SkillCategoryCardState extends State<SkillCategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isMobile = context.isMobile;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: context.reduceMotion
            ? Duration.zero
            : DurationValues.dm250.milliseconds,
        curve: AppCurves.state,
        padding: PaddingValues.p24.pAll,
        decoration: BoxDecoration(
          color: _isHovered ? colors.surface3 : colors.surface2,
          borderRadius: BorderRadius.circular(BorderValues.medium),
          border: Border.all(
            color: _isHovered ? colors.borderStrong : colors.borderSubtle,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  height: AppSize.s40.rs,
                  width: AppSize.s40.rs,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.accentMuted,
                    borderRadius: BorderRadius.circular(BorderValues.small),
                  ),
                  child: Icon(
                    widget.category.icon,
                    size: AppSize.s20,
                    color: colors.accent,
                  ),
                ),
                AppSize.s12.spaceW,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Semantics(header:) so screen readers can jump between
                      // categories (SPEC §14).
                      Semantics(
                        header: true,
                        child: CustomText.display(
                          widget.category.labelKey.tr(context),
                          fontSize: isMobile
                              ? FontSize.h3Mobile
                              : FontSize.h3Desktop,
                          textAlign: TextAlign.start,
                          height: LineHeights.tight,
                        ),
                      ),
                      AppSize.s4.spaceH,
                      CustomText(
                        widget.category.descriptionKey.tr(context),
                        fontSize: FontSize.labelDesktop,
                        color: colors.textTertiary,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSize.s20.spaceH,
            Wrap(
              spacing: AppSize.s8,
              runSpacing: AppSize.s8,
              children: <Widget>[
                for (final Skill skill in widget.skills)
                  SkillChip(skill: skill),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
