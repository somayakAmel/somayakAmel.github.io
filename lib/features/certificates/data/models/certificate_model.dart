import '../../../../core/data/json_reader.dart';
import '../../../../core/domain/entities/localized_text.dart';
import '../../domain/entities/certificate.dart';

/// Serialisation for entries in `assets/data/certificates.json`.
class CertificateModel {
  final String id;
  final LocalizedText title;
  final LocalizedText issuer;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final String? imagePath;
  final String? issuerLogoPath;

  const CertificateModel({
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

  factory CertificateModel.fromJson(Map<String, dynamic> json) =>
      CertificateModel(
        id: json.str('id'),
        title: json.localized('title'),
        issuer: json.localized('issuer'),
        issueDate: json.date('issue_date'),
        // Null means "no expiry", which is different from a missing field.
        expiryDate: json.dateOrNull('expiry_date'),
        credentialId: json.strOrNull('credential_id'),
        credentialUrl: json.strOrNull('credential_url'),
        imagePath: json.strOrNull('image_path'),
        issuerLogoPath: json.strOrNull('issuer_logo_path'),
      );

  Certificate toEntity() => Certificate(
    id: id,
    title: title,
    issuer: issuer,
    issueDate: issueDate,
    expiryDate: expiryDate,
    credentialId: credentialId,
    credentialUrl: credentialUrl,
    imagePath: imagePath,
    issuerLogoPath: issuerLogoPath,
  );
}
