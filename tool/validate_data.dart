import 'dart:io';

import 'src/data_validator.dart';
import 'src/validation_result.dart';

/// Validates `assets/data/` and `lang/` before the content can reach a build.
///
/// Run with:
///
/// ```
/// dart run tool/validate_data.dart
/// ```
///
/// Exits non-zero when any ERROR is found, so it can gate a commit or CI job.
/// Warnings (untranslated Arabic, remaining TODO placeholders) are reported but
/// do not fail the run — the scaffolding has to stay usable while the portfolio
/// is being filled in.
void main(List<String> args) {
  final Directory root = Directory(args.isNotEmpty ? args.first : '.');

  if (!Directory('${root.path}/assets/data').existsSync()) {
    stderr.writeln(
      'No assets/data directory under "${root.path}". '
      'Run this from the project root.',
    );
    exit(2);
  }

  final ValidationResult result = DataValidator(root).run();

  for (final ValidationIssue issue in result.issues) {
    (issue.isError ? stderr : stdout).writeln(issue.toString());
  }

  stdout.writeln('');
  stdout.writeln(
    '${result.errors.length} error(s), ${result.warnings.length} warning(s).',
  );

  if (result.hasErrors) {
    stdout.writeln('Content validation FAILED.');
  } else {
    stdout.writeln('Content validation passed.');
  }

  exit(result.exitCode);
}
