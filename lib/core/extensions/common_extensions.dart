import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Duration builders (ARCHITECTURE_GUIDE §15.5).
///
/// Used as `DurationValues.dm400.milliseconds`.
extension MyDurations on num {
  Duration get milliseconds => Duration(milliseconds: toInt());

  Duration get seconds => Duration(seconds: toInt());
}

/// Debug logging — a no-op in release (ARCHITECTURE_GUIDE §15.5).
///
/// [RULE] `.dLog()` is the only logging call in feature code. Never bare
/// `print()` — the linter enforces this via `avoid_print` (§22.4).
extension DebugLog on Object? {
  void dLog([String? label]) {
    if (kDebugMode) {
      developer.log('${label != null ? '$label : ' : ''}$this');
    }
  }
}

/// Colour helpers.
///
/// Uses `withValues` rather than the deprecated `withOpacity`
/// (ARCHITECTURE_GUIDE §22.19).
extension ColorsExtension on Color {
  Color getWithOpacity(double value) => withValues(alpha: value);
}

extension StringExtension on String {
  String get capitalizeFirstLetter =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  bool get isBlank => trim().isEmpty;

  bool get isNotBlank => trim().isNotEmpty;
}

extension NullableStringExtension on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  bool get isNotNullOrBlank => !isNullOrBlank;
}

/// Conditional widget wrapping, so `build()` bodies stay flat.
extension WidgetExtensions on Widget {
  /// Centres the widget.
  Widget get centered => Center(child: this);

  /// Wraps in [Expanded] with the given flex.
  Widget expanded([int flex = 1]) => Expanded(flex: flex, child: this);

  /// Wraps in [Flexible].
  Widget get flexible => Flexible(child: this);

  /// Applies [wrapper] only when [condition] holds. Keeps conditional
  /// decoration out of the widget tree as a ternary returning two subtrees.
  Widget wrapIf(bool condition, Widget Function(Widget child) wrapper) =>
      condition ? wrapper(this) : this;

  /// Removes the widget from the semantic tree — for decorative elements
  /// (SPEC §14).
  Widget get decorative => ExcludeSemantics(child: this);
}
