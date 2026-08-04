import 'package:equatable/equatable.dart';

/// Failures are RETURNED, in the domain layer (ARCHITECTURE_GUIDE §8.1).
///
/// Kept strictly separate from exceptions: exceptions are thrown by the data
/// layer and never escape it; `tryCatch` converts them into failures, which
/// travel up inside `Either<Failure, T>`.
///
/// [RULE] `Either` never reaches a widget. The cubit folds it into
/// `CustomState` (§7.4, Rule 7).
class Failure extends Equatable {
  final String? message;

  const Failure([this.message]);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

/// A content asset could not be loaded or parsed.
class DataFailure extends Failure {
  const DataFailure([super.message]);
}

/// A lookup by id or slug found nothing.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message]);
}
