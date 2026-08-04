import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/core.dart';
import 'package:portfolio/src/widgets/max_width_wrapper.dart';

/// Guards the hard responsive rule: no horizontal overflow at any width from
/// 320px up (PROJECT_SPEC §12).
///
/// Widget tests measure real geometry, which is what a screenshot of a headless
/// browser cannot tell you precisely.
Future<void> _pump(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        theme: ThemeManager.dark,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
  await tester.pump();
}

const String _longProse =
    'I build production Flutter apps with architecture that lasts, across '
    'Android, iOS and the web, with a focus on maintainability.';

void main() {
  group('ProseWidth', () {
    testWidgets('never exceeds the available width on a phone', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const Size(390, 844),
        const MaxWidthWrapper(
          child: SizedBox(
            width: double.infinity,
            child: ProseWidth(child: CustomText(_longProse)),
          ),
        ),
      );

      final Size textSize = tester.getSize(find.byType(CustomText));
      expect(textSize.width, lessThanOrEqualTo(390.0));
    });

    testWidgets('clamps to the prose measure on a wide viewport', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const Size(1440, 900),
        const MaxWidthWrapper(
          child: SizedBox(
            width: double.infinity,
            child: ProseWidth(child: CustomText(_longProse)),
          ),
        ),
      );

      final Size textSize = tester.getSize(find.byType(CustomText));
      // Clamped for readability rather than stretching the full 1200px column.
      expect(textSize.width, lessThanOrEqualTo(AppSize.maxProseWidth));
    });
  });

  group('no horizontal overflow', () {
    for (final double width in <double>[320, 375, 390, 768, 1024, 1440]) {
      testWidgets('at ${width.toInt()}px', (WidgetTester tester) async {
        await _pump(
          tester,
          Size(width, 900),
          MaxWidthWrapper(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const ProseWidth(child: CustomText(_longProse)),
                  Wrap(
                    children: <Widget>[
                      for (int i = 0; i < 12; i++)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: CustomContainer(
                            text: 'Chip $i',
                            onTap: () {},
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ).withPadding(PaddingValues.p20.pSymmetricH),
          ),
        );

        // A RenderFlex overflow paints an error banner and logs an exception;
        // asserting no exception is the strongest available signal.
        expect(tester.takeException(), isNull);

        final Size wrapperSize = tester.getSize(find.byType(MaxWidthWrapper));
        expect(wrapperSize.width, lessThanOrEqualTo(width));
      });
    }
  });
}
