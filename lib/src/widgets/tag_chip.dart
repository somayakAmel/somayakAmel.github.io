import 'package:flutter/material.dart';

import '../../core/core.dart';

/// A single pill (PROJECT_SPEC §10.2).
///
/// Shared because it has three consumers: the Tech Stack grid, project card
/// tech lists, and the project type filter.
class TagChip extends StatelessWidget {
  final String label;

  /// Filled accent treatment, for a selected filter.
  final bool isSelected;

  final VoidCallback? onTap;

  /// Small leading glyph — a technology logo, for instance.
  final Widget? leading;

  final bool dense;

  const TagChip(
    this.label, {
    super.key,
    this.isSelected = false,
    this.onTap,
    this.leading,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return CustomContainer(
      onTap: onTap,
      color: isSelected ? colors.accentMuted : colors.surface2,
      borderColor: isSelected ? colors.accent : colors.borderSubtle,
      borderRadius: BorderValues.bFull.borderAll,
      padding:
          (dense ? PaddingValues.p4 : PaddingValues.p6,
                  dense ? PaddingValues.p8 : PaddingValues.p12)
              .pSymmetricVH,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (leading != null) ...<Widget>[leading!, AppSize.s6.spaceW],
          CustomText(
            label,
            fontSize: dense ? FontSize.labelMobile : FontSize.labelDesktop,
            fontWeight: FontWeightManager.medium,
            color: isSelected ? colors.accent : colors.textSecondary,
            height: LineHeights.tight,
          ),
        ],
      ),
    );
  }
}
