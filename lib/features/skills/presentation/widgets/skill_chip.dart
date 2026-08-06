import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entities/skill.dart';

/// One skill, rendered as a pill (design brief §1).
///
/// Two states rather than a proficiency scale: core skills carry an accent
/// tint and a small marker; everything else is a neutral chip. [Skill.isCore]
/// is derived from how many projects actually used the skill, so the emphasis
/// is evidence-backed rather than self-assessed — which is what keeps this
/// clear of the progress bars and invented percentages the brief rules out.
class SkillChip extends StatefulWidget {
  final Skill skill;

  const SkillChip({super.key, required this.skill});

  @override
  State<SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<SkillChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool core = widget.skill.isCore;
    final bool lit = _isHovered;

    final Color background = core
        ? (lit ? colors.accentMuted : colors.accentMuted)
        : (lit ? colors.surface3 : colors.surface2);
    final Color border = core
        ? colors.accent.getWithOpacity(lit ? 0.9 : 0.45)
        : (lit ? colors.borderStrong : colors.borderSubtle);
    final Color label = core
        ? colors.accent
        : (lit ? colors.textPrimary : colors.textSecondary);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Semantics(
        // Screen readers get the reason for the emphasis, not just the tint —
        // colour is never the sole carrier of meaning (SPEC §14).
        label: core
            ? '${widget.skill.name}. ${StringsManager.coreSkillLabel.tr(context)}'
            : widget.skill.name,
        child: ExcludeSemantics(
          child: AnimatedContainer(
            duration: context.reduceMotion
                ? Duration.zero
                : DurationValues.dm150.milliseconds,
            curve: AppCurves.state,
            padding: (PaddingValues.p8, PaddingValues.p12).pSymmetricVH,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(BorderValues.bFull),
              border: Border.all(color: border),
              // The soft accent glow the brief asks for, on core chips only —
              // a glow on every chip would be decoration rather than hierarchy.
              boxShadow: core && lit
                  ? <BoxShadow>[
                      BoxShadow(
                        color: colors.accent.getWithOpacity(0.22),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.skill.logoPath != null) ...<Widget>[
                  SizedBox(
                    height: AppSize.s14.rs,
                    width: AppSize.s14.rs,
                    child: CustomImage(
                      path: widget.skill.logoPath,
                      fit: BoxFit.contain,
                      monogram: widget.skill.name,
                    ),
                  ),
                  AppSize.s6.spaceW,
                ] else if (core) ...<Widget>[
                  Icon(
                    IconsManager.sparkle,
                    size: AppSize.s12,
                    color: colors.accent,
                  ),
                  AppSize.s6.spaceW,
                ],
                CustomText(
                  widget.skill.name,
                  fontSize: FontSize.labelDesktop,
                  fontWeight: core
                      ? FontWeightManager.semiBold
                      : FontWeightManager.medium,
                  color: label,
                  height: LineHeights.tight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
