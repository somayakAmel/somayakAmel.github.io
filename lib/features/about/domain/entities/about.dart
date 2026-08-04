import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/localized_text.dart';

/// Identity and narrative (PROJECT_SPEC §8.3).
///
/// A pure domain entity: no JSON knowledge, no Flutter import. The data layer's
/// `AboutModel` owns serialisation and produces this via `toEntity()`
/// (full entity separation, guide §22.11 option (a)).
class About extends Equatable {
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
  final List<Highlight> highlights;

  const About({
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
    this.highlights = const <Highlight>[],
  });

  /// A resume is offered only when one is actually bundled.
  bool get hasResume => resumePath != null && resumePath!.trim().isNotEmpty;

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
    name,
    roleTitle,
    tagline,
    bio,
    yearsOfExperience,
    location,
    email,
    phone,
    avatarPath,
    resumePath,
    highlights,
  ];
}

/// A headline stat in the About section — "5+ Years", "20+ Apps Shipped".
class Highlight extends Equatable {
  final String value;
  final LocalizedText label;
  final String? iconKey;

  const Highlight({required this.value, required this.label, this.iconKey});

  @override
  List<Object?> get props => <Object?>[value, label, iconKey];
}
