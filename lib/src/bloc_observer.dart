import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/extensions/common_extensions.dart';

/// [RULE] Every log is guarded by `kDebugMode` (ARCHITECTURE_GUIDE §3.10).
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    if (kDebugMode) '${bloc.runtimeType} created'.dLog('bloc');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) '${bloc.runtimeType} $change'.dLog('bloc');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) '${bloc.runtimeType} $error'.dLog('bloc error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    if (kDebugMode) '${bloc.runtimeType} closed'.dLog('bloc');
  }
}
