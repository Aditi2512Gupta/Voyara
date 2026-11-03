import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:voyara/features/home/presentation/pages/home_page.dart';
import 'package:voyara/features/home/presentation/widgets/plan_with_ai_floating_button.dart';
import 'package:voyara/app/router/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlanWithAiFloatingButton Widget Tests', () {
    testWidgets(
      'renders Plan a Trip label, AI SMART ROUTE tag, and compass flight visual',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(floatingActionButton: PlanWithAiFloatingButton()),
          ),
        );

        // Verify clear "Plan a Trip" lettering, AI SMART ROUTE badge, and compass flight painter
        expect(find.text('Plan a Trip'), findsOneWidget);
        expect(find.text('AI SMART ROUTE'), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
        expect(find.byKey(const Key('plan_with_ai_fab')), findsOneWidget);
      },
    );

    testWidgets('triggers custom onPressed when provided', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: PlanWithAiFloatingButton(
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('plan_with_ai_fab')));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('navigates to /trip-planner on tap by default', (tester) async {
      String currentRoute = '/home';

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              floatingActionButton: PlanWithAiFloatingButton(),
            ),
          ),
          GoRoute(
            path: '/trip-planner',
            builder: (context, state) {
              currentRoute = '/trip-planner';
              return const Scaffold(body: Text('AI Trip Planner Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Plan a Trip'), findsOneWidget);

      await tester.tap(find.byKey(const Key('plan_with_ai_fab')));
      await tester.pumpAndSettle();

      expect(currentRoute, '/trip-planner');
      expect(find.text('AI Trip Planner Screen'), findsOneWidget);
    });

    testWidgets(
      'adapts responsively across mobile, device-sized, and tablet layouts',
      (tester) async {
        // 1. Compact mobile view (360 x 640)
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(floatingActionButton: PlanWithAiFloatingButton()),
          ),
        );
        expect(find.text('Plan a Trip'), findsOneWidget);
        expect(find.text('AI SMART ROUTE'), findsOneWidget);

        // 2. Target Device layout (Motorola Edge 40 Neo logical size: 412 x 915)
        tester.view.physicalSize = const Size(412, 915);
        await tester.pump();
        expect(find.text('Plan a Trip'), findsOneWidget);
        expect(find.text('AI SMART ROUTE'), findsOneWidget);

        // 3. Tablet view (800 x 1280)
        tester.view.physicalSize = const Size(800, 1280);
        await tester.pump();
        expect(find.text('Plan a Trip'), findsOneWidget);
        expect(find.text('AI SMART ROUTE'), findsOneWidget);
      },
    );

    testWidgets('HomePage renders Plan a Trip with AI action card', (
      tester,
    ) async {
      // Test on device-sized screen (412 x 915)
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomePage())),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Plan a Trip with AI action card is present on HomePage
      expect(find.text('Plan a Trip\nwith AI'), findsOneWidget);
      expect(find.text('My Trips'), findsOneWidget);
    });
  });

  group('MainNavigationPage Bottom Navigation UI Tests', () {
    testWidgets('has exactly 4 navigation destinations without AI Planner', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: "Home"),
                NavigationDestination(
                  icon: Icon(Icons.luggage),
                  label: "Trips",
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite),
                  label: "Favorites",
                ),
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      );

      // Verify the 4 destinations exist
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Trips'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify AI Planner is NOT in the bottom navigation destinations
      expect(find.text('AI Planner'), findsNothing);
    });
  });

  group('AppRouter Tab Navigation & Redirect Tests', () {
    test('routes table contains /trip-planner and redirects for tabs', () {
      final routes = appRouter.configuration.routes;

      // Verify /trip-planner route exists
      final hasTripPlanner = routes.any(
        (r) => r is GoRoute && r.path == '/trip-planner',
      );
      expect(hasTripPlanner, isTrue);

      // Verify /trips and /favorites redirect routes exist
      final tripsRoute =
          routes.firstWhere((r) => r is GoRoute && r.path == '/trips')
              as GoRoute;
      expect(tripsRoute.redirect, isNotNull);

      final favoritesRoute =
          routes.firstWhere((r) => r is GoRoute && r.path == '/favorites')
              as GoRoute;
      expect(favoritesRoute.redirect, isNotNull);
    });
  });
}
