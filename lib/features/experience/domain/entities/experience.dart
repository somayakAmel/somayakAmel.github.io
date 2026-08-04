import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/localized_text.dart';
import '../../../../core/managers/strings_manager.dart';

/// One role in the work history (PROJECT_SPEC §8.3).
class Experience extends Equatable {
  final String id;
  final LocalizedText company;
  final LocalizedText role;
  final EmploymentType employmentType;
  final DateTime startDate;

  /// Null means "present" — rendered with an accent marker on the timeline
  /// (PROJECT_SPEC §7.6).
  final DateTime? endDate;

  final LocalizedText location;
  final List<LocalizedText> achievements;
  final List<String> technologies;
  final String? logoPath;

  const Experience({
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

  /// [RULE] Derivations live on the entity, not in widgets (SPEC §8.5).
  bool get isCurrent => endDate == null;

  /// Whole months between start and end (or now, when current).
  int get durationMonths {
    final DateTime end = endDate ?? DateTime.now();
    final int months =
        (end.year - startDate.year) * 12 + (end.month - startDate.month);
    // A role that started and ended in the same month still counts as one.
    return months < 1 ? 1 : months;
  }

  int get durationYearsPart => durationMonths ~/ 12;

  int get durationMonthsPart => durationMonths % 12;

  @override
  List<Object?> get props => <Object?>[
    id,
    company,
    role,
    employmentType,
    startDate,
    endDate,
    location,
    achievements,
    technologies,
    logoPath,
  ];
}

enum EmploymentType {
  fullTime,
  partTime,
  freelance,
  contract,
  internship;

  String get labelKey => switch (this) {
    EmploymentType.fullTime => StringsManager.employmentFullTime,
    EmploymentType.partTime => StringsManager.employmentPartTime,
    EmploymentType.freelance => StringsManager.employmentFreelance,
    EmploymentType.contract => StringsManager.employmentContract,
    EmploymentType.internship => StringsManager.employmentInternship,
  };
}
