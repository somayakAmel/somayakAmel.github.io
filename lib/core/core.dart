/// The single public entry point for the core layer.
///
/// [RULE] Feature code imports this barrel, not individual core files
/// (ARCHITECTURE_GUIDE §18.4).
///
/// [RULE] core/ never imports anything from features/ (PROJECT_SPEC §16).
library;

export 'data/json_reader.dart';
export 'data/local_json_datasource.dart';
export 'data/try_catch.dart';
export 'design_system/design_system.dart';
export 'domain/entities/localized_text.dart';
export 'domain/errors/exceptions.dart';
export 'domain/errors/failures.dart';
export 'domain/usecases/base_usecase.dart';
export 'extensions/extensions.dart';
export 'localization/app_localizations.dart';
export 'managers/managers.dart';
export 'state/custom_state.dart';

// Re-export third-party packages every feature needs, so a feature file
// imports one or two barrels rather than a long list (guide §1.3).
export 'package:dartz/dartz.dart' show Either, Left, Right;
export 'package:equatable/equatable.dart';
