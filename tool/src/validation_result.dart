/// Severity of a validation finding.
///
/// Only [ValidationSeverity.error] fails the run. Warnings surface content that
/// is incomplete but still renders — an untranslated Arabic string, a TODO
/// marker — because failing the build on those would make the placeholder
/// scaffolding unusable during development.
enum ValidationSeverity { error, warning }

class ValidationIssue {
  final ValidationSeverity severity;

  /// The check that produced this, e.g. `unique-slugs`, `asset-paths`.
  final String check;

  /// The file the issue was found in, relative to the project root.
  final String file;

  final String message;

  const ValidationIssue({
    required this.severity,
    required this.check,
    required this.file,
    required this.message,
  });

  const ValidationIssue.error({
    required this.check,
    required this.file,
    required this.message,
  }) : severity = ValidationSeverity.error;

  const ValidationIssue.warning({
    required this.check,
    required this.file,
    required this.message,
  }) : severity = ValidationSeverity.warning;

  bool get isError => severity == ValidationSeverity.error;

  @override
  String toString() =>
      '${isError ? 'ERROR' : 'WARN '} [$check] $file: $message';
}

/// The accumulated findings of a validation run.
class ValidationResult {
  final List<ValidationIssue> issues = <ValidationIssue>[];

  void add(ValidationIssue issue) => issues.add(issue);

  void addAll(Iterable<ValidationIssue> newIssues) => issues.addAll(newIssues);

  List<ValidationIssue> get errors =>
      issues.where((ValidationIssue i) => i.isError).toList(growable: false);

  List<ValidationIssue> get warnings =>
      issues.where((ValidationIssue i) => !i.isError).toList(growable: false);

  bool get hasErrors => errors.isNotEmpty;

  /// The process exit code: non-zero when any error was found.
  int get exitCode => hasErrors ? 1 : 0;
}
