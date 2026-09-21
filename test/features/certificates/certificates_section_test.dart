import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/core/core.dart';
import 'package:portfolio/features/certificates/domain/entities/certificate.dart';
import 'package:portfolio/features/certificates/domain/usecases/get_certificates_usecase.dart';
import 'package:portfolio/features/certificates/presentation/cubit/certificates_cubit.dart';
import 'package:portfolio/features/certificates/presentation/widgets/certificates_section.dart';
import 'package:portfolio/src/service_locator.dart';
import 'package:portfolio/src/widgets/section_container.dart';
import 'package:portfolio/src/widgets/section_state_builder.dart';
import 'package:visibility_detector/visibility_detector.dart';

class _MockUsecase extends Mock implements GetCertificatesUsecase {}

Certificate _certificate(String id) => Certificate(
  id: id,
  title: LocalizedText.same(id),
  issuer: const LocalizedText.same('Issuer'),
  issueDate: DateTime(2024),
);

late _MockUsecase _usecase;

Future<void> _pump(
  WidgetTester tester,
  Either<Failure, List<Certificate>> result,
) async {
  when(() => _usecase(any())).thenAnswer((_) async => result);

  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        theme: ThemeManager.dark,
        home: const Scaffold(
          body: SingleChildScrollView(child: CertificatesSection()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => registerFallbackValue(GetCertificatesParams.preview));

  setUp(() {
    // SectionContainer's VisibilityDetector batches its callbacks behind a
    // 500ms timer. The empty case mounts the section while loading and then
    // removes it, which leaves that timer pending past the end of the test.
    VisibilityDetectorController.instance.updateInterval = Duration.zero;

    _usecase = _MockUsecase();
    sl.registerLazySingleton<GetCertificatesUsecase>(() => _usecase);
    sl.registerFactory<CertificatesCubit>(() => CertificatesCubit(sl()));
  });

  tearDown(() => sl.reset());

  group('empty', () {
    testWidgets('renders nothing at all when there are no certificates', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const Right<Failure, List<Certificate>>(<Certificate>[]),
      );

      // No heading, no "View all", no empty plate, and no section padding.
      expect(find.byType(SectionContainer), findsNothing);
      expect(find.byType(SectionEmptyState), findsNothing);
      expect(tester.getSize(find.byType(CertificatesSection)).height, 0);
    });
  });

  group('not empty', () {
    testWidgets('renders the section when certificates exist', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        Right<Failure, List<Certificate>>(<Certificate>[_certificate('a')]),
      );

      expect(find.byType(SectionContainer), findsOneWidget);
      expect(find.byType(CertificatesGrid), findsOneWidget);
      expect(
        tester.getSize(find.byType(CertificatesSection)).height,
        greaterThan(0),
      );
    });

    testWidgets('keeps the section on failure, so retry stays reachable', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const Left<Failure, List<Certificate>>(
          DataFailure('could not read the file'),
        ),
      );

      // A broken fetch must not look like a visitor with no certificates.
      expect(find.byType(SectionContainer), findsOneWidget);
      expect(find.byType(CustomErrorWidget), findsOneWidget);
    });
  });
}
