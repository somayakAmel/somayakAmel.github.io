import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/extensions/responsive_extension.dart';
import 'package:portfolio/core/managers/breakpoints_manager.dart';

/// Guards the responsive sizing contract (PROJECT_SPEC §12, risk R-8).
///
/// Two regressions this locks down, both found by screenshotting real
/// breakpoints rather than by any unit test:
///
///  1. The clamp keyed off `Breakpoints.tablet` (900) instead of the design
///     width (440), so the whole 600-899 band inflated — 16pt rendered ~22pt.
///  2. `.rs` averaged the height and width factors. At 1440x900 that averages
///     0.94 and 3.27 into 2.11, so a 34pt heading asked for 71pt.
Future<void> _pumpAt(WidgetTester tester, Size size, VoidCallback body) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (BuildContext context, Widget? child) => MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            body();
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
}

void main() {
  group('responsive clamp', () {
    testWidgets('does not inflate at the tablet breakpoint', (
      WidgetTester tester,
    ) async {
      late double scaled;
      await _pumpAt(tester, const Size(768, 1024), () => scaled = 16.0.rs);

      // The regression: this returned ~22 when the threshold was 900.
      expect(scaled, lessThanOrEqualTo(16.0));
    });

    testWidgets('does not inflate on a wide desktop viewport', (
      WidgetTester tester,
    ) async {
      late double font;
      late double gap;
      await _pumpAt(tester, const Size(1440, 900), () {
        font = 34.0.rs;
        gap = 24.0.rw;
      });

      expect(font, lessThanOrEqualTo(34.0));
      expect(gap, lessThanOrEqualTo(24.0));
    });

    testWidgets('still scales DOWN below the design width', (
      WidgetTester tester,
    ) async {
      late double scaled;
      await _pumpAt(tester, const Size(320, 568), () => scaled = 16.0.rs);

      // Small phones must shrink, or layouts overflow.
      expect(scaled, lessThan(16.0));
      expect(scaled, greaterThan(0));
    });

    testWidgets('rs never exceeds the width factor', (
      WidgetTester tester,
    ) async {
      // A wide-but-short viewport is the shape that broke the average.
      late double bySize;
      late double byWidth;
      await _pumpAt(tester, const Size(1200, 600), () {
        bySize = 20.0.rs;
        byWidth = 20.0.rw;
      });

      expect(bySize, lessThanOrEqualTo(byWidth));
    });
  });

  group('Breakpoints', () {
    test('maps widths to the expected device bands', () {
      expect(Breakpoints.fromWidth(320), DeviceType.mobile);
      expect(Breakpoints.fromWidth(599), DeviceType.mobile);
      expect(Breakpoints.fromWidth(600), DeviceType.tablet);
      expect(Breakpoints.fromWidth(899), DeviceType.tablet);
      expect(Breakpoints.fromWidth(900), DeviceType.desktop);
      expect(Breakpoints.fromWidth(1239), DeviceType.desktop);
      expect(Breakpoints.fromWidth(1240), DeviceType.largeDesktop);
    });

    test('isWide covers tablet and above', () {
      expect(DeviceType.mobile.isWide, isFalse);
      expect(DeviceType.tablet.isWide, isTrue);
      expect(DeviceType.desktop.isWide, isTrue);
    });

    test('isDesktopClass excludes tablet', () {
      // Hover affordances and the inline anchor nav key off this.
      expect(DeviceType.tablet.isDesktopClass, isFalse);
      expect(DeviceType.desktop.isDesktopClass, isTrue);
    });
  });
}
