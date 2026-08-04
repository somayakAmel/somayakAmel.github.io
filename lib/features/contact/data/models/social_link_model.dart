import '../../../../core/data/json_reader.dart';
import '../../../../core/domain/entities/localized_text.dart';
import '../../domain/entities/social_link.dart';

/// Serialisation for entries in `assets/data/social_links.json`.
class SocialLinkModel {
  final String id;
  final SocialPlatform platform;
  final LocalizedText label;
  final String url;
  final String iconKey;
  final bool showInFooter;
  final int order;

  const SocialLinkModel({
    required this.id,
    required this.platform,
    required this.label,
    required this.url,
    required this.iconKey,
    this.showInFooter = true,
    this.order = 0,
  });

  factory SocialLinkModel.fromJson(Map<String, dynamic> json) {
    final SocialPlatform platform = enumFromValue(
      SocialPlatform.values,
      json.strOrNull('platform'),
      fallback: SocialPlatform.other,
    );
    return SocialLinkModel(
      id: json.str('id'),
      platform: platform,
      label: json.localized('label'),
      url: json.str('url'),
      // Falls back to the platform name, which IconsManager.fromKey resolves
      // for the known platforms — so icon_key is optional in practice.
      iconKey: json.strOrNull('icon_key') ?? platform.name,
      showInFooter: json.boolOr('show_in_footer', true),
      order: json.intOr('order'),
    );
  }

  SocialLink toEntity() => SocialLink(
    id: id,
    platform: platform,
    label: label,
    url: url,
    iconKey: iconKey,
    showInFooter: showInFooter,
    order: order,
  );
}
