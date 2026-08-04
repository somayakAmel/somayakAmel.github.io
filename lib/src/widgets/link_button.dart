import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../core/utils/link_launcher.dart';
import '../service_locator.dart';

/// An external-link action (PROJECT_SPEC §10.2).
///
/// Owns the launch call, the failure toast, and the clipboard fallback in ONE
/// place — so every link in the app behaves identically when the OS refuses to
/// open it, which on Web is common for `mailto:` (SPEC §7.8).
class LinkButton extends StatelessWidget {
  final String url;
  final String label;
  final IconData? icon;

  /// Copied to the clipboard when the launch fails. Defaults to [url].
  final String? copyValue;

  final bool isFilled;
  final bool expand;

  const LinkButton({
    super.key,
    required this.url,
    required this.label,
    this.icon,
    this.copyValue,
    this.isFilled = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color foreground = isFilled ? colors.onAccent : colors.textPrimary;

    return CustomContainer(
      onTap: () => _open(context),
      isFilled: isFilled,
      color: isFilled ? colors.accent : colors.surface2,
      borderColor: isFilled ? null : colors.borderSubtle,
      borderRadius: BorderValues.b12.borderAll,
      padding: (PaddingValues.p12, PaddingValues.p20).pSymmetricVH,
      hoverLift: true,
      semanticLabel: label,
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: AppSize.s16, color: foreground),
            AppSize.s8.spaceW,
          ],
          Flexible(
            child: CustomText(
              label,
              fontSize: FontSize.captionDesktop,
              fontWeight: FontWeightManager.semiBold,
              color: foreground,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    // Captured before the await, so nothing reaches across the async gap
    // (guide §22.6).
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String copiedMsg = StringsManager.couldNotOpenLink.tr(context);

    final LaunchOutcome outcome = await sl<LinkLauncher>().open(
      url,
      fallbackCopyValue: copyValue,
    );

    if (outcome == LaunchOutcome.opened) return;
    messenger.showSnackBar(SnackBar(content: Text(copiedMsg)));
  }
}
