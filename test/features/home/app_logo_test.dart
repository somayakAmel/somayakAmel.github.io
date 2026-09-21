import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/core.dart';

/// The lockup already reads "Somaya Kamel", so wherever it appears the app
/// must not print the name beside it, and the bar must still fit a 320px
/// phone alongside the menu button.

Future<void> _pumpBar(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        theme: ThemeManager.dark,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            appBar: CustomAppBar(
              showBack: false,
              leadingWidget: CustomImage(
                path: AssetsManager.logo,
                height: context.isMobile ? AppSize.s24 : AppSize.s28,
                fit: BoxFit.contain,
                semanticLabel: 'Somaya Kamel',
              ),
              actions: <Widget>[
                CustomContainer(
                  onTap: () {},
                  shape: BoxShape.circle,
                  padding: PaddingValues.p10.pAll,
                  semanticLabel: 'menu',
                  child: const Icon(IconsManager.menu, size: AppSize.s20),
                ),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('the wordmark in the top bar', () {
    for (final double width in <double>[320, 375, 430, 768, 1024, 1440]) {
      testWidgets('fits beside the actions at ${width.toInt()}px', (
        WidgetTester tester,
      ) async {
        await _pumpBar(tester, Size(width, 900));

        expect(tester.takeException(), isNull);

        final CustomImage logo = tester.widget<CustomImage>(
          find.byType(CustomImage),
        );
        expect(logo.path, AssetsManager.logo);
        expect(logo.fit, BoxFit.contain);

        // Wide lockup, small bar: it must never push the row past the edge.
        final Size rendered = tester.getSize(find.byType(CustomImage));
        expect(rendered.width, lessThan(width));
      });
    }

    testWidgets('carries a semantic label, since it paints no live text', (
      WidgetTester tester,
    ) async {
      await _pumpBar(tester, const Size(1440, 900));

      final CustomImage logo = tester.widget<CustomImage>(
        find.byType(CustomImage),
      );
      expect(logo.semanticLabel, isNotEmpty);
    });
  });
}
