import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/core.dart';
import 'package:portfolio/features/projects/domain/entities/project_summary.dart';
import 'package:portfolio/features/projects/presentation/widgets/featured_projects_section.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_card.dart';
import 'package:portfolio/src/widgets/max_width_wrapper.dart';

/// Guards the rule that a project card is sized by its CONTENT, never by a
/// fixed height (PROJECT_SPEC §12).
///
/// A card whose height is pinned by its parent overflows the moment the
/// content needs one pixel more than the guess — which is exactly what a short
/// viewport, a long tagline or a wrapped chip row produce. These tests measure
/// real geometry at the widths a phone actually reports.

const String _longTagline =
    'Internal field application for the foundation, digitising beneficiary '
    'case collection across every governorate it works in.';

List<ProjectSummary> _projects({int count = 3}) =>
    List<ProjectSummary>.generate(
      count,
      (int i) => ProjectSummary(
        slug: 'project_$i',
        title: const LocalizedText.same('A Fairly Long Project Title'),
        tagline: const LocalizedText.same(_longTagline),
        domain: const LocalizedText.same('Nonprofit Sector'),
        coverPath: 'assets/covers/project_$i.jpeg',
        type: ProjectType.client,
        // Three chips, long enough to wrap onto a second row on a phone.
        primaryTech: const <String>[
          'Clean Architecture',
          'State Management',
          'SQLite',
        ],
        detailFile: 'assets/data/projects/project_$i.json',
      ),
      growable: false,
    );

/// One short-content project, for comparing against the long-content set.
ProjectSummary _shortProject(int i) => ProjectSummary(
  slug: 'short_$i',
  title: const LocalizedText.same('Short'),
  tagline: const LocalizedText.same('One line.'),
  domain: const LocalizedText.same('Tools'),
  coverPath: 'assets/covers/short_$i.jpeg',
  type: ProjectType.client,
  primaryTech: const <String>['Dart'],
  detailFile: 'assets/data/projects/short_$i.json',
);

/// Mirrors how SectionContainer hosts the layout on Home.
Future<void> _pumpProjects(
  WidgetTester tester,
  Size size,
  List<ProjectSummary> projects,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        theme: ThemeManager.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: MaxWidthWrapper(
              child: ProjectsLayout(projects: projects),
            ).withPadding(PaddingValues.p20.pSymmetricH),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pump(WidgetTester tester, Size size, {int count = 3}) =>
    _pumpProjects(tester, size, _projects(count: count));

void main() {
  group('no overflow at any viewport', () {
    // Short viewports are the failure case: the mobile carousel scaled its
    // fixed height by the VIEWPORT HEIGHT, so the shorter the phone the less
    // room the card got, while the content it had to hold stayed the same.
    for (final Size size in <Size>[
      const Size(320, 568),
      const Size(375, 667),
      const Size(390, 844),
      const Size(430, 932),
      const Size(768, 1024),
      const Size(1024, 768),
      const Size(1440, 900),
    ]) {
      testWidgets('at ${size.width.toInt()}x${size.height.toInt()}', (
        WidgetTester tester,
      ) async {
        await _pump(tester, size);

        // A RenderFlex overflow paints the stripe banner and logs here.
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('content-driven height', () {
    const Size phone = Size(390, 844);
    const Size desktop = Size(1440, 900);

    testWidgets('the phone rail shrinks to shorter content', (
      WidgetTester tester,
    ) async {
      await _pumpProjects(tester, phone, _projects());
      final double tall = tester.getSize(find.byType(ProjectsLayout)).height;

      await _pumpProjects(tester, phone, <ProjectSummary>[
        _shortProject(0),
        _shortProject(1),
        _shortProject(2),
      ]);
      final double short = tester.getSize(find.byType(ProjectsLayout)).height;

      // Same viewport, same card count, less text. Under a fixed height these
      // two are identical.
      expect(short, lessThan(tall));
    });

    testWidgets('the desktop row shrinks to shorter content', (
      WidgetTester tester,
    ) async {
      await _pumpProjects(tester, desktop, _projects());
      final double tall = tester.getSize(find.byType(ProjectsLayout)).height;

      await _pumpProjects(tester, desktop, <ProjectSummary>[
        _shortProject(0),
        _shortProject(1),
        _shortProject(2),
      ]);
      final double short = tester.getSize(find.byType(ProjectsLayout)).height;

      // childAspectRatio made this a pure function of the column width, so
      // the two were identical no matter how much text the cards held.
      expect(short, lessThan(tall));
    });

    testWidgets('the phone rail still snaps to whole cards', (
      WidgetTester tester,
    ) async {
      await _pumpProjects(tester, phone, _projects());

      final ScrollableState rail = tester.state(
        find.descendant(
          of: find.byType(ProjectsLayout),
          matching: find.byType(Scrollable),
        ),
      );
      expect(rail.position.pixels, 0);

      await tester.fling(
        find.byType(ProjectCard).first,
        const Offset(-120, 0),
        800,
      );
      await tester.pumpAndSettle();

      // Three cards, so the rail scrolls exactly two pitches end to end. A
      // flick must land on the first of them, not between cards.
      final double pitch = rail.position.maxScrollExtent / 2;
      expect(rail.position.pixels, closeTo(pitch, 1.0));
    });

    testWidgets('cards in a row still share one height', (
      WidgetTester tester,
    ) async {
      // A row mixing a long-tagline card with a one-liner: the cards must
      // line up, and they must do it at the TALLER card's content height.
      await _pumpProjects(tester, desktop, <ProjectSummary>[
        _projects().first,
        _shortProject(1),
        _shortProject(2),
      ]);

      final double first = tester
          .getSize(find.byType(ProjectCard).at(0))
          .height;
      final double second = tester
          .getSize(find.byType(ProjectCard).at(1))
          .height;
      final double third = tester
          .getSize(find.byType(ProjectCard).at(2))
          .height;

      expect(second, closeTo(first, 0.5));
      expect(third, closeTo(first, 0.5));
    });
  });
}
