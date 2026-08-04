import 'package:flutter/material.dart';

import '../core/core.dart';
import '../features/certificates/presentation/screens/certificates_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/projects/presentation/screens/image_viewer_screen.dart';
// project_details_screen re-exports ProjectDetailsArguments.
import '../features/projects/presentation/screens/project_details_screen.dart';
import '../features/projects/presentation/screens/projects_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

/// [RULE] Imperative, named routing via `onGenerateRoute`. No go_router, no
/// nested navigators (ARCHITECTURE_GUIDE §9.1).
class RoutesManager {
  const RoutesManager._();

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final Widget screen = _screenFor(settings);

    // Platform-adaptive transitions are configured once in ThemeManager's
    // pageTransitionsTheme, so MaterialPageRoute picks the right one per
    // platform rather than each route deciding.
    return MaterialPageRoute<dynamic>(
      settings: settings,
      // The viewer presents as a modal: it overlays content rather than being
      // a destination, and this is what traps focus inside it (SPEC §14).
      fullscreenDialog:
          Uri.parse(settings.name ?? '').path == ImageViewerScreen.route,
      builder: (_) => screen,
    );
  }

  static Widget _screenFor(RouteSettings settings) {
    // Web deep links arrive as "/project_details?slug=motary", so the path and
    // the query are split before matching (PROJECT_SPEC §5).
    final Uri uri = Uri.parse(settings.name ?? SplashScreen.route);

    switch (uri.path) {
      case SplashScreen.route:
        return const SplashScreen();

      case HomeScreen.route:
        return const HomeScreen();

      case ProjectsScreen.route:
        return const ProjectsScreen();

      case CertificatesScreen.route:
        return const CertificatesScreen();

      case ImageViewerScreen.route:
        final Object? viewerArgs = settings.arguments;
        if (viewerArgs is ImageViewerArguments) {
          return ImageViewerScreen(args: viewerArgs);
        }
        // The viewer carries its images in memory, so it cannot be deep-linked
        // the way a project can. A direct URL falls through to 404 rather than
        // opening an empty gallery.
        return const UndefinedRouteScreen();

      case ProjectDetailsScreen.route:
        final Object? args = settings.arguments;
        if (args is ProjectDetailsArguments) {
          return ProjectDetailsScreen(args: args);
        }
        // No arguments means a direct URL entry or a page refresh on Web. The
        // slug comes from the query string instead, and the screen re-fetches
        // — which is what makes every project link shareable (SPEC §5).
        final String? slug = uri.queryParameters['slug'];
        if (slug != null && slug.isNotEmpty) {
          return ProjectDetailsScreen(
            args: ProjectDetailsArguments(slug: slug),
          );
        }
        return const UndefinedRouteScreen();

      default:
        return const UndefinedRouteScreen();
    }
  }
}

/// 404.
///
/// A real screen here, unlike in the guide where it was a debug affordance:
/// Flutter Web exposes URLs publicly, so this is reachable by a visitor and
/// must look intentional rather than alarming (PROJECT_SPEC §6, S7).
class UndefinedRouteScreen extends StatelessWidget {
  const UndefinedRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomText(
              '404',
              fontSize: FontSize.displayDesktop,
              fontWeight: FontWeightManager.bold,
              color: context.colors.accent,
            ),
            AppSize.s12.spaceH,
            CustomText(
              StringsManager.pageNotFound.tr(context),
              fontSize: FontSize.bodyLargeDesktop,
              color: context.colors.textSecondary,
            ),
            AppSize.s32.spaceH,
            CustomContainer(
              text: StringsManager.backToHome.tr(context),
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                HomeScreen.route,
                (Route<dynamic> route) => false,
              ),
              padding: (PaddingValues.p12, PaddingValues.p24).pSymmetricVH,
            ),
          ],
        ),
      ),
    );
  }
}
