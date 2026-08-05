import 'package:flutter/material.dart';

import '../../core/core.dart';

/// Branches a [CustomState] into the four canonical UI states.
///
/// [RULE] The order is fixed: loading → success → failure → fallback
/// (ARCHITECTURE_GUIDE §3.7, Rule 22).
///
/// [RULE] The failure branch always offers a retry that re-invokes the same
/// fetch (§3.7).
///
/// ## Why this widget exists
///
/// Without it, all eight Home sections hand-roll the same if/else-if ladder,
/// and the order drifts. This is the single most valuable shared widget in the
/// app (PROJECT_SPEC §10.2): one implementation, one order, one retry
/// affordance, enforced everywhere by construction.
class SectionStateBuilder<T> extends StatelessWidget {
  final CustomState<T> state;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback onRetry;

  /// Shown while loading. A skeleton matching the final layout beats a spinner
  /// for anything above the fold (SPEC §7.1).
  final Widget? loading;

  /// Shown when the fetch succeeded but produced nothing renderable.
  final Widget? empty;

  /// True when [data] should be treated as empty.
  final bool Function(T data)? isEmpty;

  /// Compact error treatment, for sections embedded in a tight space.
  final bool compactError;

  const SectionStateBuilder({
    super.key,
    required this.state,
    required this.builder,
    required this.onRetry,
    this.loading,
    this.empty,
    this.isEmpty,
    this.compactError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return loading ??
          Padding(
            padding: PaddingValues.p48.pSymmetricV,
            child: const Center(child: CustomLoading()),
          );
    }

    if (state.isSuccess && state.data != null) {
      final T data = state.data as T;
      final bool blank = isEmpty?.call(data) ?? false;
      if (blank) {
        return empty ?? const SectionEmptyState();
      }
      return builder(context, data);
    }

    if (state.isFailure) {
      return Center(
        child: CustomErrorWidget(
          error: state.error,
          onTap: onRetry,
          compact: compactError,
        ),
      ).withPadding(PaddingValues.p32.pSymmetricV);
    }

    return const SizedBox.shrink();
  }
}

/// Icon + title + subtitle, for a section whose content list is empty
/// (PROJECT_SPEC §10.2).
class SectionEmptyState extends StatelessWidget {
  final String? title;
  final IconData? icon;

  const SectionEmptyState({super.key, this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon ?? IconsManager.empty,
          size: AppSize.s32,
          color: colors.textTertiary,
        ),
        AppSize.s12.spaceH,
        CustomText(
          title ?? StringsManager.nothingHereYet.tr(context),
          fontSize: FontSize.captionDesktop,
          color: colors.textTertiary,
          textAlign: TextAlign.center,
        ),
      ],
    ).centered.withPadding(PaddingValues.p32.pSymmetricV);
  }
}
