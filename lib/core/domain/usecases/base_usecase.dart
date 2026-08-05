import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

/// Base use case contracts (ARCHITECTURE_GUIDE §2.6).
///
/// The method is named `call`, which makes use cases callable objects:
/// `await _getProjectsUsecase(params)` rather than `.execute(params)`.
///
/// [RULE] Every use case:
///  - lives in its own file, named `<verb>_<noun>_usecase.dart`;
///  - extends [BaseUseCase] or [BaseUseCaseNoParam];
///  - takes its repository as the only constructor dependency;
///  - has a body that is ONLY `return tryCatch(tryFunction: () => _repo.x());`.
///
/// [RULE] A use case contains no logic beyond the `tryCatch` wrapper. If you
/// need branching, it belongs in the repository (Rule 6).
// `Type` shadows dart:core's Type. Kept anyway: it is the guide's exact
// signature (§2.6) and appears in every use case in the codebase, so fidelity
// to the documented contract outweighs the lint.
// ignore_for_file: avoid_types_as_parameter_names

abstract class BaseUseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class BaseUseCaseNoParam<Type> {
  Future<Either<Failure, Type>> call();
}
