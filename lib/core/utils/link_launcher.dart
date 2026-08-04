import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../extensions/common_extensions.dart';

/// Result of a launch attempt, so the caller can decide how to inform the user.
enum LaunchOutcome {
  /// The OS opened the target.
  opened,

  /// The OS refused, so the raw value was copied to the clipboard instead.
  copiedInstead,

  /// Nothing could be done.
  failed,
}

/// Opens external links, with a clipboard fallback.
///
/// ## Why the fallback matters
///
/// `mailto:` frequently does nothing on Web — no mail client registered, or the
/// browser silently blocks it. Without a fallback the visitor taps "Email me"
/// and experiences the portfolio as broken at the exact moment they were trying
/// to make contact. Copying the address turns a dead end into a working one
/// (PROJECT_SPEC §7.8).
class LinkLauncher {
  const LinkLauncher();

  /// Opens [url]. On failure, copies [fallbackCopyValue] (or the raw URL) to
  /// the clipboard and reports [LaunchOutcome.copiedInstead].
  Future<LaunchOutcome> open(
    String url, {
    String? fallbackCopyValue,
  }) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return LaunchOutcome.failed;

    try {
      final bool launched = await launchUrl(
        uri,
        // External links leave the app; on Web this opens a new tab, which is
        // what a recruiter expects from a GitHub or App Store link.
        mode: LaunchMode.externalApplication,
      );
      if (launched) return LaunchOutcome.opened;
    } catch (e) {
      e.dLog('LinkLauncher failed for $url');
    }

    return _copy(fallbackCopyValue ?? _humanValue(url));
  }

  Future<LaunchOutcome> _copy(String value) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      return LaunchOutcome.copiedInstead;
    } catch (e) {
      e.dLog('Clipboard write failed');
      return LaunchOutcome.failed;
    }
  }

  /// Strips the scheme so the copied value is the address or number itself,
  /// not `mailto:someone@example.com`.
  String _humanValue(String url) {
    for (final String scheme in const <String>['mailto:', 'tel:', 'sms:']) {
      if (url.startsWith(scheme)) return url.substring(scheme.length);
    }
    return url;
  }
}
