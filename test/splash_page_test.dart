import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyara/features/startup/presentation/pages/splash_page.dart';
import 'package:voyara/features/startup/startup_controller.dart';

class FakeStartupController extends StartupController {
  const FakeStartupController();

  @override
  Future<bool> isLoggedIn() async => false;
}

void main() {
  group('SplashPage Widget Tests', () {
    testWidgets('Renders properly on tall phone (Motorola Edge 40 Neo ratio)', (
      WidgetTester tester,
    ) async {
      // Simulate Motorola Edge 40 Neo (tall 20:9 ratio)
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(controller: FakeStartupController()),
        ),
      );

      // Verify widget builds without error
      expect(find.byType(SplashPage), findsOneWidget);
      expect(find.byType(Image), findsWidgets);

      // Pump initial animation frames
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      // Pump through flight animation
      await tester.pump(const Duration(milliseconds: 800));
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 1000));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Airplane animation completes through t=1.0 without curve assertion error',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.5;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: SplashPage(controller: FakeStartupController()),
          ),
        );

        // Step precisely through all frames from 0 to 3000ms
        // to ensure t reaches exactly 1.0 (and any floating point rounding)
        for (int i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 50));
          expect(tester.takeException(), isNull);
        }

        // Allow completion
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Renders properly on standard phone (19.5:9 ratio)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(controller: FakeStartupController()),
        ),
      );

      expect(find.byType(SplashPage), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders properly on tablet (4:3 ratio)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1536, 2048);
      tester.view.devicePixelRatio = 2.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(controller: FakeStartupController()),
        ),
      );

      expect(find.byType(SplashPage), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  });
}
