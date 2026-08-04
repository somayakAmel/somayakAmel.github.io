import '../../../../core/data/json_reader.dart';
import '../../../../core/domain/entities/localized_text.dart';
import '../../domain/entities/experience.dart';

/// Serialisation for entries in `assets/data/experience.json`.
class ExperienceModel {
  final String id;
  final LocalizedText company;
  final LocalizedText role;
  final EmploymentType employmentType;
  final DateTime startDate;
  final DateTime? endDate;
  final LocalizedText location;
  final List<LocalizedText> achievements;
  final List<String> technologies;
  final String? logoPath;

  const ExperienceModel({
    required this.id,
    required this.company,
    required this.role,
    required this.employmentType,
    required this.startDate,
    required this.location,
    this.endDate,
    this.achievements = const <LocalizedText>[],
    this.technologies = const <String>[],
    this.logoPath,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) =>
      ExperienceModel(
        id: json.str('id'),
        company: json.localized('company'),
        role: json.localized('role'),
        employmentType: enumFromValue(
          EmploymentType.values,
          json.strOrNull('employment_type'),
          fallback: EmploymentType.fullTime,
        ),
        // A malformed start date falls back to the epoch, which sorts the entry
        // last rather than throwing (see JsonReader.date).
        startDate: json.date('start_date'),
        // Null is meaningful here: it means "present", not "missing".
        endDate: json.dateOrNull('end_date'),
        location: json.localized('location'),
        achievements: json.localizedList('achievements'),
        technologies: json.strList('technologies'),
        logoPath: json.strOrNull('logo_path'),
      );

  Experience toEntity() => Experience(
    id: id,
    company: company,
    role: role,
    employmentType: employmentType,
    startDate: startDate,
    endDate: endDate,
    location: location,
    achievements: achievements,
    technologies: technologies,
    logoPath: logoPath,
  );
}
