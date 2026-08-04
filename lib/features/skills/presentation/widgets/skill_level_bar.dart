import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entities/skill.dart';

/// A three-segment proficiency indicator (PROJECT_SPEC §7.4).
///
/// [RULE] Colour is never the sole carrier of meaning: the level also has a
/// text label beside it and a semantic label for screen readers (SPEC §14).
class SkillLevelBar extends StatelessWidget {
  final SkillLevel level;

  const SkillLevelBar({super.key, required this.level});

  static const int _segments = 3;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Semantics(
      label: level.labelKey.tr(context),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < _segments; i++)
              Container(
                width: AppSize.s16.rw,
                height: AppSize.s4,
                margin: EdgeInsetsDirectional.only(end: AppSize.s4.rw),
                decoration: BoxDecoration(
                  color: i < level.filledSegments
                      ? colors.accent
                      : colors.borderStrong,
                  borderRadius: BorderRadius.circular(BorderValues.bFull),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
