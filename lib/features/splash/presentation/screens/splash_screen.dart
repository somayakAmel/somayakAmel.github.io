import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../src/service_locator.dart';
import '../../../home/presentation/screens/home_screen.dart';

/// Preloads above-the-fold content, then navigates to Home
/// (PROJECT_SPEC §6, S1).
///
/// ## Why the timeout exists
///
/// Blocking on all JSON before Home renders is clean but adds latency on Web,
/// where the engine has already cost seconds. So Splash awaits only what the
/// first viewport needs, and gives up after a hard ceiling: if anything hangs,
/// navigate anyway and let each section show its own error state. A data
/// problem must never trap the visitor on a splash screen (SPEC risk R-9).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String route = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _preloadAndGo();
  }

  Future<void> _preloadAndGo() async {
    final LocalJsonDataSource jsonSource = sl<LocalJsonDataSource>();

    try {
      await Future.wait(<Future<void>>[
        jsonSource.readJson(AssetsManager.aboutData),
        jsonSource.readJson(AssetsManager.projectsIndexData),
      ]).timeout(DurationValues.splashTimeout.milliseconds);
    } catch (e) {
      // Swallowed deliberately: a missing or slow asset is not a reason to
      // block. The sections that need it will surface their own retry.
      e.dLog('Splash preload');
    }

    // [RULE] Guard BuildContext across the async gap (guide §22.6).
    if (!mounted) return;
    await Navigator.of(context).pushNamedAndRemoveUntil(
      HomeScreen.route,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: CustomText.display(
        StringsManager.appName.tr(context),
        fontSize: FontSize.h1Desktop,
      ),
    ),
  );
}
