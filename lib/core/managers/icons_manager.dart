import 'package:flutter/material.dart';

/// Icon registry.
///
/// The app uses Material icons rather than a bundled SVG set: it needs roughly
/// twenty glyphs, all of which Material covers, and `uses-material-design: true`
/// already ships the font. Bundling twenty SVGs to re-draw arrows and mail
/// icons would be cost without benefit.
///
/// SVG remains the rule for *logos* (technology, company, issuer), which arrive
/// from JSON `logo_path` fields and render through `CustomSvg`.
///
/// [RULE] Feature code references `IconsManager.x`, never `Icons.x` directly,
/// so the icon set can be swapped in one place.
class IconsManager {
  const IconsManager._();

  // Navigation
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
  static const IconData menu = Icons.menu_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData scrollDown = Icons.keyboard_arrow_down_rounded;
  static const IconData externalLink = Icons.open_in_new_rounded;

  // Actions
  static const IconData download = Icons.file_download_outlined;
  static const IconData copy = Icons.copy_rounded;
  static const IconData retry = Icons.refresh_rounded;
  static const IconData language = Icons.translate_rounded;

  // Contact / social — Material has no brand glyphs, so social links use
  // these neutral stand-ins until brand SVGs land in assets/logos/.
  static const IconData mail = Icons.mail_outline_rounded;
  static const IconData phone = Icons.phone_outlined;
  static const IconData chat = Icons.chat_bubble_outline_rounded;
  static const IconData link = Icons.link_rounded;
  static const IconData code = Icons.code_rounded;

  // Content
  static const IconData work = Icons.work_outline_rounded;
  static const IconData school = Icons.school_outlined;
  static const IconData verified = Icons.verified_outlined;
  static const IconData location = Icons.place_outlined;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData rocket = Icons.rocket_launch_outlined;
  static const IconData devices = Icons.devices_rounded;
  static const IconData layers = Icons.layers_outlined;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData empty = Icons.inbox_outlined;

  // Skill categories
  static const IconData stateManagement = Icons.account_tree_outlined;
  static const IconData cloud = Icons.cloud_outlined;
  static const IconData tools = Icons.build_outlined;
  static const IconData sparkle = Icons.auto_awesome_outlined;

  /// Maps an `icon_key` string from JSON to a glyph.
  ///
  /// [RULE] Unknown keys fall back rather than throwing — a typo in a content
  /// file must degrade one tile, never crash a section (SPEC §8.4).
  static IconData fromKey(String? key) => switch (key) {
    'calendar' => calendar,
    'rocket' => rocket,
    'devices' => devices,
    'layers' => layers,
    'work' => work,
    'school' => school,
    'verified' => verified,
    'location' => location,
    'mail' => mail,
    'phone' => phone,
    'chat' || 'whatsapp' => chat,
    'code' || 'github' => code,
    'link' || 'linkedin' => link,
    _ => link,
  };
}
