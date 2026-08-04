import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/localized_text.dart';

/// A credential (PROJECT_SPEC §8.3).
class Certificate extends Equatable {
  final String id;
  final LocalizedText title;
  final LocalizedText issuer;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final String? imagePath;
  final String? issuerLogoPath;

  const Certificate({
    required this.id,
    required this.title,
    required this.issuer,
    required this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
    this.imagePath,
    this.issuerLogoPath,
  });

  /// [RULE] Derivations live on the entity, not in widgets (SPEC §8.5).
  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  /// A Verify action is offered only when there is something to verify.
  bool get isVerifiable =>
      credentialUrl != null && credentialUrl!.trim().isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    issuer,
    issueDate,
    expiryDate,
    credentialId,
    credentialUrl,
    imagePath,
    issuerLogoPath,
  ];
}
