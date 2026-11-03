import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyara/features/home/presentation/widgets/my_trips_card.dart';
import 'package:voyara/features/home/presentation/widgets/home_app_bar.dart';
import 'package:voyara/features/profile/data/models/user_profile_model.dart';
import 'package:voyara/features/profile/providers/profile_provider.dart';
import 'package:voyara/core/providers/notification_provider.dart';
import 'package:voyara/features/trip_planner/data/models/saved_trip_model.dart';
import 'package:voyara/features/trip_planner/presentation/pages/saved_trips_page.dart';
import 'package:voyara/features/trip_planner/providers/saved_trip_provider.dart';

void main() {
  final sampleTrip = SavedTripModel(
    id: 'test_trip_1',
    destination: 'Manali, Himachal Pradesh',
    latitude: 32.2432,
    longitude: 77.1892,
    startDate: DateTime(2026, 11, 15),
    days: 4,
    travelers: 2,
    budget: 25000,
    interests: const ['Adventure', 'Nature', 'Mountains'],
    overview: 'A scenic 4-day mountain getaway to Manali.',
    budgetSummary: 'Estimated total cost ₹25,000 for 2 travelers.',
    dailyItinerary: const [],
    packingChecklist: const ['Warm clothes', 'Trekking shoes', 'Sunscreen'],
    safetyTips: const ['Check weather before venturing into high altitudes'],
    localTips: const ['Try local Himachali cuisine in Old Manali'],
    createdAt: DateTime(2026, 10, 1),
  );

  group('MyTripsCard Widget Tests', () {
    testWidgets('Renders My Trips card with empty state description', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savedTripsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(home: Scaffold(body: MyTripsCard())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Trips'), findsOneWidget);
      expect(find.text('SAVED PLANS'), findsOneWidget);
      expect(
        find.text('View and manage your saved AI itineraries'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.luggage_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('Renders My Trips card with trip count badge', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savedTripsProvider.overrideWith(
              (ref) => Stream.value([sampleTrip]),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: MyTripsCard())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Trips'), findsOneWidget);
      expect(find.text('1 SAVED'), findsOneWidget);
      expect(find.text('1 saved itinerary ready to explore'), findsOneWidget);
    });
  });

  group('HomeAppBar My Trips Button Test', () {
    testWidgets('HomeAppBar renders My Trips button in header cluster', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationsProvider.overrideWith((ref) => Stream.value([])),
            profileProvider.overrideWith(
              (ref) => Future.value(
                UserProfileModel(
                  name: 'Traveler',
                  email: 'traveler@example.com',
                  photoUrl: '',
                  phone: '1234567890',
                  joinedOn: DateTime.now(),
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: HomeAppBar())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.luggage_outlined), findsOneWidget);
      expect(find.byTooltip('My Trips'), findsOneWidget);
    });
  });

  group('SavedTripsPage Standalone Tests', () {
    testWidgets('Renders empty state when there are no saved trips', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savedTripsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(home: SavedTripsPage(title: 'My Trips')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Trips'), findsOneWidget);
      expect(find.text('No saved trips yet'), findsOneWidget);
      expect(
        find.text('Plan a trip with AI to save your dream itineraries here.'),
        findsOneWidget,
      );
      expect(find.text('Plan a Trip with AI'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Renders saved trips list with destination, dates, budget', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savedTripsProvider.overrideWith(
              (ref) => Stream.value([sampleTrip]),
            ),
          ],
          child: const MaterialApp(home: SavedTripsPage(title: 'Saved Trips')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Saved Trips'), findsOneWidget);
      expect(find.text('Manali, Himachal Pradesh'), findsOneWidget);
      expect(
        find.textContaining('15/11/2026 • 4 days • 2 travelers'),
        findsOneWidget,
      );
      expect(find.text('Budget: ₹25000'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.travel_explore), findsOneWidget);
    });
  });
}
