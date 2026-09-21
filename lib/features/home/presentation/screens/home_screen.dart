import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../src/widgets/app_footer.dart';
import '../../../../src/widgets/language_toggle.dart';
import '../../../../src/widgets/mobile_nav_sheet.dart';
import '../../../about/presentation/widgets/about_section.dart';
import '../../../certificates/presentation/widgets/certificates_section.dart';
import '../../../contact/presentation/widgets/contact_section.dart';
import '../../../experience/presentation/widgets/experience_section.dart';
import '../../../projects/presentation/widgets/featured_projects_section.dart';
import '../../../skills/presentation/widgets/skills_section.dart';
import '../widgets/hero_section.dart';

/// The scrolling composite (PROJECT_SPEC §6, S2).
///
/// [RULE] HomeScreen owns nothing but layout and scroll. Each `<Feature>Section`
/// provides its own cubit, fetches its own data, and renders its own states —
/// so reordering Home is moving one line in the children list (SPEC §10.3).
///
/// Section order is deliberate (design system §Layout Philosophy): Projects sit
/// SECOND, immediately after the hero, because projects get interviews. About
/// follows as context for work the reader has already seen, rather than as a
/// preamble they have to get through first.
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
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

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

  List<NavDestination> get _destinations => <NavDestination>[
    NavDestination(
      labelKey: StringsManager.navWork,
      onTap: () => _scrollTo(_projectsKey),
    ),
    NavDestination(
      labelKey: StringsManager.navAbout,
      onTap: () => _scrollTo(_aboutKey),
    ),
    NavDestination(
      labelKey: StringsManager.navSkills,
      onTap: () => _scrollTo(_skillsKey),
    ),
    NavDestination(
      labelKey: StringsManager.navExperience,
      onTap: () => _scrollTo(_experienceKey),
    ),
    NavDestination(
      labelKey: StringsManager.navContact,
      onTap: () => _scrollTo(_contactKey),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        isScrolled: _isScrolled,
        showBack: false,
        // The lockup replaces the wordmark text rather than joining it: it
        // already reads "Somaya Kamel", and printing the name beside it would
        // say the same thing twice.
        leadingWidget: CustomImage(
          path: AssetsManager.logo,
          height: context.isMobile ? AppSize.s24 : AppSize.s28,
          fit: BoxFit.contain,
          semanticLabel: StringsManager.appName.tr(context),
        ),
        actions: <Widget>[
          if (context.isDesktopClass) ...<Widget>[
            for (final NavDestination destination in _destinations)
              _NavLink(
                labelKey: destination.labelKey,
                onTap: destination.onTap,
              ),
            AppSize.s8.spaceW,
            const LanguageToggle(),
          ] else
            // Mobile and tablet collapse the nav into a bottom sheet (§12).
            CustomContainer(
              onTap: () => MobileNavSheet.show(context, _destinations),
              shape: BoxShape.circle,
              color: context.colors.surface2,
              padding: PaddingValues.p10.pAll,
              semanticLabel: StringsManager.openMenu.tr(context),
              child: Icon(
                IconsManager.menu,
                size: AppSize.s20,
                color: context.colors.textPrimary,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        // Preserves scroll offset across push/pop, so returning from a project
        // detail lands the reader where they left off (SPEC risk R-4).
        key: const PageStorageKey<String>('home-scroll'),
        child: Column(
          children: <Widget>[
            // Order is deliberate (design system §Layout Philosophy):
            // Projects sit SECOND, immediately after the hero, because
            // projects get interviews. About follows as context for work the
            // reader has already seen.
            HeroSection(onScrollToWork: () => _scrollTo(_projectsKey)),
            FeaturedProjectsSection(anchorKey: _projectsKey),
            AboutSection(anchorKey: _aboutKey),
            SkillsSection(anchorKey: _skillsKey),
            ExperienceSection(anchorKey: _experienceKey),
            const CertificatesSection(),
            ContactSection(anchorKey: _contactKey),
            const AppFooter(),
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
