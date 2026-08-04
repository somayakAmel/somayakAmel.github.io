import 'package:equatable/equatable.dart';

/// Exceptions are THROWN, in the data layer (ARCHITECTURE_GUIDE §8.1).
///
/// The guide's original defines seven exception types because it faces an HTTP
/// API with a status-code taxonomy. This app reads bundled JSON assets, where
/// exactly two things can go wrong: the asset is missing, or its contents do
/// not parse. A larger hierarchy would be empty ceremony (PROJECT_SPEC §19).
///
/// [RULE] Both extend [AppException], so a single `on AppException` catch
/// handles the whole family.
abstract class AppException extends Equatable implements Exception {
  final String? message;

  const AppException([this.message]);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

/// The asset could not be read — missing from the bundle, or not declared in
/// `pubspec.yaml`.
///
/// The undeclared-folder case is the most common cause in practice, because
/// `assets/projects/` is not recursive (SPEC risk R-7).
class AssetLoadException extends AppException {
  const AssetLoadException([super.message = 'Could not load asset']);
}

/// The asset was read but its contents are not valid JSON, or do not match the
/// expected shape.
class DataParseException extends AppException {
  const DataParseException([super.message = 'Could not parse data']);
}

/// A lookup by id or slug found nothing — a project slug in the index whose
/// detail file has no matching entry, for instance.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found']);
}
