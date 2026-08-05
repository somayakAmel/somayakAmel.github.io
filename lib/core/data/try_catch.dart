import 'dart:async';

import 'package:dartz/dartz.dart';

import '../domain/errors/exceptions.dart';
import '../domain/errors/failures.dart';
import '../extensions/common_extensions.dart';

/// Testing flag, ported from the guide's `TestingEnvironment`
/// (ARCHITECTURE_GUIDE §8.2). Suppresses crash reporting under test so error
/// paths can be exercised without polluting output.
class TestingEnvironment {
  const TestingEnvironment._();

  static bool isTesting = false;

  static void setTestingMode() => isTesting = true;
}

/// The bridge between the exception hierarchy (thrown, data layer) and the
/// failure hierarchy (returned, domain layer). This is the single place error
/// policy lives (ARCHITECTURE_GUIDE §8.2).
///
/// [RULE] Repositories throw. Use cases convert, via this function. Cubits fold
/// the resulting `Either` into `CustomState`.
///
/// `Completer().completeError` is the crash-reporting hook: it surfaces the
/// error to Flutter's zone error handler so a service like Sentry can pick it
/// up, without coupling this code to any SDK.
Future<Either<Failure, T>> tryCatch<T>({
  required Future<T> Function() tryFunction,
}) async {
  try {
    return Right(await tryFunction());
  } on NotFoundException catch (e, stack) {
    _report(e, stack);
    return Left(NotFoundFailure(e.message));
  } on AppException catch (e, stack) {
    _report(e, stack);
    return Left(DataFailure(e.message));
  } catch (e, stack) {
    _report(e, stack);
    return Left(Failure(e.toString()));
  }
}

void _report(Object error, StackTrace stack) {
  error.dLog('tryCatch');
  if (!TestingEnvironment.isTesting) {
    Completer<void>().completeError(error, stack);
  }
}
