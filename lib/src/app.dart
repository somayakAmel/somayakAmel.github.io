import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;

import '../core/core.dart';
import '../core/localization/locale_cubit.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import 'routes_manager.dart';
import 'service_locator.dart';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  /// Enables navigation and snackbars from non-widget code
  /// (ARCHITECTURE_GUIDE §9.5).
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// The design size the responsive extensions scale against. Below the tablet
  /// breakpoint they scale as the guide specifies; at and above it they clamp,
  /// so a desktop monitor does not inflate the type ladder (SPEC §12).
  static const Size designSize = Size(440, 956);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocaleCubit>(
      // A lazy singleton, so the same instance backs the app bar toggle and
      // MaterialApp's locale (guide §4.3).
      create: (_) => sl<LocaleCubit>()..getSavedLang(),
      child: ScreenUtilInit(
        designSize: designSize,
        splitScreenMode: true,
        minTextAdapt: true,
        builder: (BuildContext context, Widget? child) {
          // watch, not read: switching language must rebuild MaterialApp so the
          // delegates reload and Directionality flips for Arabic.
          final Locale locale = context.watch<LocaleCubit>().state;

          return MaterialApp(
            title: 'Portfolio',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,

            theme: ThemeManager.dark,
            // v1 ships dark only. Adding light is: pass ThemeManager.light here
            // and drive themeMode from a ThemeCubit — no widget changes
            // (SPEC §15).
            themeMode: ThemeMode.dark,
            darkTheme: ThemeManager.dark,

            initialRoute: SplashScreen.route,
            onGenerateRoute: RoutesManager.generateRoute,

            locale: locale,
            localizationsDelegates:
                AppLocalizationsSetup.localizationsDelegates,
            supportedLocales: AppLocalizationsSetup.supportedLocales,
            localeResolutionCallback:
                AppLocalizationsSetup.localeResolutionCallback,
          );
        },
      ),
    );
  }
}
