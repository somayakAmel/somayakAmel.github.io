import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../about/presentation/widgets/about_section.dart';
import '../../../projects/presentation/widgets/featured_projects_section.dart';
import '../widgets/hero_section.dart';

/// The scrolling composite (PROJECT_SPEC §6, S2).
///
/// [RULE] HomeScreen owns nothing but layout and scroll. Each `<Feature>Section`
/// provides its own cubit, fetches its own data, and renders its own states —
/// so reordering Home is moving one line in [_sections] (SPEC §10.3).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollController;

  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();

  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    // [RULE] Controller created here and disposed below — never in build().
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final bool scrolled = _scrollController.offset > AppSize.s24;
    if (scrolled == _isScrolled) return;
    setState(() => _isScrolled = scrolled);
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final BuildContext? target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: context.reduceMotion
          ? Duration.zero
          : DurationValues.dm400.milliseconds,
      curve: AppCurves.entrance,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        isScrolled: _isScrolled,
        showBack: false,
        leadingWidget: CustomText(
          StringsManager.appName.tr(context),
          fontSize: FontSize.h3Desktop,
          fontWeight: FontWeightManager.bold,
        ),
        actions: <Widget>[
          if (context.isDesktopClass) ...<Widget>[
            _NavLink(
              labelKey: StringsManager.navAbout,
              onTap: () => _scrollTo(_aboutKey),
            ),
            _NavLink(
              labelKey: StringsManager.navWork,
              onTap: () => _scrollTo(_projectsKey),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        // Preserves scroll offset across push/pop, so returning from a project
        // detail lands the reader where they left off (SPEC risk R-4).
        key: const PageStorageKey<String>('home-scroll'),
        child: Column(
          children: <Widget>[
            HeroSection(onScrollToWork: () => _scrollTo(_projectsKey)),
            AboutSection(anchorKey: _aboutKey),
            FeaturedProjectsSection(anchorKey: _projectsKey),
            AppSize.s96.spaceH,
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String labelKey;
  final VoidCallback onTap;

  const _NavLink({required this.labelKey, required this.onTap});

  @override
  Widget build(BuildContext context) => CustomContainer(
    onTap: onTap,
    transparentButton: true,
    padding: (PaddingValues.p8, PaddingValues.p12).pSymmetricVH,
    child: CustomText(
      labelKey.tr(context),
      fontSize: FontSize.captionDesktop,
      fontWeight: FontWeightManager.medium,
      color: context.colors.textSecondary,
    ),
  );
}
