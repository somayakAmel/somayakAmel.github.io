import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app.dart';
import 'src/bloc_observer.dart';
import 'src/service_locator.dart';

/// [RULE] Pre-runApp setup only. Never contains widgets other than runApp
/// (ARCHITECTURE_GUIDE §1.4).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Clean URLs (/projects) instead of hash fragments (/#/projects), so every
    // route is shareable and looks like a real web address (SPEC §5).
    usePathUrlStrategy();
  } else {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  await initAppModule();

  Bloc.observer = const AppBlocObserver();

  runApp(const PortfolioApp());
}
