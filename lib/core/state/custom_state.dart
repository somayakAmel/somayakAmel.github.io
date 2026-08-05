import 'package:equatable/equatable.dart';

enum Status { initial, loading, success, failure }

/// The core state primitive (ARCHITECTURE_GUIDE §3.1).
///
/// A single generic status wrapper, rather than sealed classes per operation.
/// One `CustomState<T>` field per independent async operation on the cubit's
/// state class.
///
/// ## Two fixes adopted from the guide's own §22.9
///
/// 1. It lives in `core/state/`, not in a widgets folder. It is a state type,
///    not a widget.
/// 2. It extends [Equatable] with all three fields in `props`. In the original,
///    state comparison depended on `CustomState` identity, which could suppress
///    legitimate rebuilds.
///
/// Design points preserved from the guide:
///  - private unnamed constructor + named factories, so only valid combinations
///    are constructible;
///  - all constructors are `const`, so `const CustomState.initial()` works as a
///    default field value;
///  - boolean getters, so widgets read as prose and never compare enums inline.
class CustomState<T> extends Equatable {
  final Status status;
  final T? data;
  final String? error;

  const CustomState._({required this.status, this.data, this.error});

  const CustomState.initial() : this._(status: Status.initial);

  /// Preserves any previously-held [data] on the prior state object.
  const CustomState.loading() : this._(status: Status.loading);

  /// Drops previously-held data when transitioning to loading — for reloads
  /// where showing stale content would be wrong.
  const CustomState.loadingWithClear()
    : this._(status: Status.loading, data: null);

  const CustomState.success(T this.data) : status = Status.success, error = null;

  const CustomState.failure(String this.error)
    : status = Status.failure,
      data = null;

  bool get isInitial => status == Status.initial;

  bool get isLoading => status == Status.loading;

  bool get isSuccess => status == Status.success;

  bool get isFailure => status == Status.failure;

  /// True when there is data to render, whatever the status — useful for
  /// keeping content on screen during a background refresh.
  bool get hasData => data != null;

  @override
  List<Object?> get props => [status, data, error];

  @override
  String toString() => 'CustomState<$T>($status, data: $data, error: $error)';
}
