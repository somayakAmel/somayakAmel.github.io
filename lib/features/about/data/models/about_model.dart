import '../../../../core/data/json_reader.dart';
import '../../../../core/domain/entities/localized_text.dart';
import '../../domain/entities/about.dart';

/// Serialisation for `assets/data/about.json` (PROJECT_SPEC §9).
///
/// [RULE] `fromJson` is a factory; fields are final; parsing is defensive —
/// a malformed content file degrades one section, never crashes the app
/// (guide §6.3).
class AboutModel {
  final LocalizedText name;
  final LocalizedText roleTitle;
  final LocalizedText tagline;
  final LocalizedText bio;
  final int yearsOfExperience;
  final LocalizedText location;
  final String email;
  final String? phone;
  final String? avatarPath;
  final String? resumePath;
  final List<HighlightModel> highlights;

  const AboutModel({
    required this.name,
    required this.roleTitle,
    required this.tagline,
    required this.bio,
    required this.yearsOfExperience,
    required this.location,
    required this.email,
    this.phone,
    this.avatarPath,
    this.resumePath,
    this.highlights = const <HighlightModel>[],
  });

  factory AboutModel.fromJson(Map<String, dynamic> json) => AboutModel(
    name: json.localized('name'),
    roleTitle: json.localized('role_title'),
    tagline: json.localized('tagline'),
    bio: json.localized('bio'),
    yearsOfExperience: json.intOr('years_of_experience'),
    location: json.localized('location'),
    email: json.str('email'),
    phone: json.strOrNull('phone'),
    avatarPath: json.strOrNull('avatar_path'),
    resumePath: json.strOrNull('resume_path'),
    highlights: json
        .objList('highlights')
        .map(HighlightModel.fromJson)
        .toList(growable: false),
  );

  About toEntity() => About(
    name: name,
    roleTitle: roleTitle,
    tagline: tagline,
    bio: bio,
    yearsOfExperience: yearsOfExperience,
    location: location,
    email: email,
    phone: phone,
    avatarPath: avatarPath,
    resumePath: resumePath,
    highlights: highlights
        .map((HighlightModel e) => e.toEntity())
        .toList(growable: false),
  );
}

class HighlightModel {
  final String value;
  final LocalizedText label;
  final String? iconKey;

  const HighlightModel({
    required this.value,
    required this.label,
    this.iconKey,
  });

  factory HighlightModel.fromJson(Map<String, dynamic> json) => HighlightModel(
    value: json.str('value'),
    label: json.localized('label'),
    iconKey: json.strOrNull('icon_key'),
  );

  Highlight toEntity() =>
      Highlight(value: value, label: label, iconKey: iconKey);
}
