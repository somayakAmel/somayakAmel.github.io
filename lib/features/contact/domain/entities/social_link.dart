import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/localized_text.dart';

/// A way to reach the portfolio owner (PROJECT_SPEC §8.3).
class SocialLink extends Equatable {
  final String id;
  final SocialPlatform platform;
  final LocalizedText label;

  /// The FULL url, including scheme (`mailto:`, `https://wa.me/`).
  ///
  /// Stored complete in JSON rather than assembled in Dart, so adding a
  /// platform requires no code change (PROJECT_SPEC §9).
  final String url;

  final String iconKey;
  final bool showInFooter;
  final int order;

  const SocialLink({
    required this.id,
    required this.platform,
    required this.label,
    required this.url,
    required this.iconKey,
    this.showInFooter = true,
    this.order = 0,
  });

  /// The value copied to the clipboard when a launch fails — the address
  /// itself, not the scheme-prefixed url (PROJECT_SPEC §7.8).
  String get copyValue {
    for (final String scheme in const <String>['mailto:', 'tel:', 'sms:']) {
      if (url.startsWith(scheme)) return url.substring(scheme.length);
    }
    return url;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    platform,
    label,
    url,
    iconKey,
    showInFooter,
    order,
  ];
}

enum SocialPlatform {
  github,
  linkedin,
  email,
  whatsapp,
  phone,
  twitter,
  medium,
  other,
}
