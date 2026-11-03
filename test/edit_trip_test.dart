import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyara/features/trip_planner/data/models/saved_trip_model.dart';
import 'package:voyara/features/trip_planner/data/models/travel_interest_model.dart';
import 'package:voyara/features/trip_planner/data/repositories/saved_trip_repository.dart';
import 'package:voyara/features/trip_planner/presentation/pages/edit_trip_page.dart';
import 'package:voyara/features/trip_planner/presentation/pages/saved_trip_details_page.dart';
import 'package:voyara/features/trip_planner/providers/saved_trip_provider.dart';
import 'package:voyara/features/trip_planner/providers/travel_interest_provider.dart';

import 'package:voyara/features/trip_planner/data/models/trip_plan_model.dart';
import 'package:voyara/features/trip_planner/data/models/trip_plan_request.dart';
import 'package:voyara/features/trip_planner/data/repositories/trip_planner_repository.dart';
import 'package:voyara/features/trip_planner/data/services/travel_interest_service.dart';
import 'package:voyara/features/trip_planner/providers/trip_planner_provider.dart';

class MockSavedTripRepository implements SavedTripRepository {
  SavedTripModel? lastUpdatedTrip;

  @override
  Future<void> saveTrip(SavedTripModel trip) async {
    lastUpdatedTrip = trip;
  }

  @override
  Future<void> updateTrip(SavedTripModel trip) async {
    lastUpdatedTrip = trip;
  }

  @override
  Stream<List<SavedTripModel>> getTrips() {
    return Stream.value([]);
  }

  @override
  Future<void> deleteTrip(String id) async {}
}

class MockTripPlannerRepository implements TripPlannerRepository {
  TripPlanRequest? lastRequest;

  @override
  Future<TripPlanModel> generatePlan(TripPlanRequest request) async {
    lastRequest = request;
    return TripPlanModel(
      destination: request.destination,
      startDate: request.startDate,
      endDate: request.startDate.add(Duration(days: request.days - 1)),
      travelers: request.travelers,
      budget: request.budget,
      interests: request.interests,
      overview: 'Regenerated overview for ${request.destination}',
      budgetSummary: 'Regenerated budget breakdown: ₹${request.budget}',
      days: [
        TripDayModel(
          day: 1,
          date: '1/12/2026',
          morning: 'Regenerated morning activity',
          afternoon: 'Regenerated afternoon activity',
          evening: 'Regenerated evening activity',
          meals: 'Local delicacies',
          transport: 'Metro',
          estimatedCost: '₹4,000',
          estimatedCostValue: 4000,
        ),
      ],
      packingChecklist: ['New Sunglasses'],
      safetyTips: ['Updated safety note'],
      localTips: ['Updated local insight'],
    );
  }
}

void main() {
  final initialTrip = SavedTripModel(
    id: 'trip_100',
    destination: 'Goa',
    latitude: 15.2993,
    longitude: 74.1240,
    startDate: DateTime(2026, 12, 1),
    days: 4,
    budget: 25000,
    travelers: 2,
    interests: ['Beach', 'Nightlife'],
    overview: 'A wonderful beach holiday in Goa.',
    budgetSummary: 'Estimated total cost is 25000.',
    dailyItinerary: [
      const SavedTripDayModel(
        day: 1,
        date: '1/12/2026',
        morning: 'Arrive at Goa and check into resort',
        afternoon: 'Relax at Baga Beach',
        evening: 'Dinner at Britto’s',
        meals: 'Seafood lunch and dinner',
        transport: 'Taxi',
        estimatedCost: '₹3,000',
        estimatedCostValue: 3000,
      ),
    ],
    packingChecklist: ['Swimwear', 'Sunscreen'],
    safetyTips: ['Swim in designated areas'],
    localTips: ['Rent a scooter for easy travel'],
    createdAt: DateTime(2026, 10, 1),
  );

  testWidgets(
    'EditTripPage loads initial values and regenerates plan on planning changes',
    (tester) async {
      final mockRepo = MockSavedTripRepository();
      final mockTripPlannerRepo = MockTripPlannerRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savedTripRepositoryProvider.overrideWithValue(mockRepo),
            tripPlannerRepositoryProvider.overrideWithValue(
              mockTripPlannerRepo,
            ),
            travelInterestsProvider.overrideWith(
              (ref) => Future.value([
                const TravelInterestModel(id: '1', name: 'Beach'),
                const TravelInterestModel(id: '2', name: 'Adventure'),
                const TravelInterestModel(id: '3', name: 'Culture'),
              ]),
            ),
          ],
          child: MaterialApp(home: EditTripPage(trip: initialTrip)),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial values loaded into the form
      expect(find.text('Goa'), findsOneWidget);
      expect(find.text('25000'), findsOneWidget);
      expect(find.text('4 Days'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Start Date: 1/12/2026'), findsOneWidget);
      expect(find.text('Beach'), findsOneWidget);

      // Edit budget
      final budgetField = find.widgetWithText(TextField, '25000');
      await tester.enterText(budgetField, '35000');
      await tester.pump();

      // Tap on Save Changes
      final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
      expect(saveButton, findsOneWidget);
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify AI generation was called
      expect(mockTripPlannerRepo.lastRequest, isNotNull);
      expect(mockTripPlannerRepo.lastRequest!.budget, 35000);

      // Verify repository was called with regenerated plan and same trip ID
      expect(mockRepo.lastUpdatedTrip, isNotNull);
      expect(mockRepo.lastUpdatedTrip!.id, 'trip_100');
      expect(mockRepo.lastUpdatedTrip!.budget, 35000);
      expect(mockRepo.lastUpdatedTrip!.destination, 'Goa');
      expect(
        mockRepo.lastUpdatedTrip!.overview,
        'Regenerated overview for Goa',
      );
      expect(
        mockRepo.lastUpdatedTrip!.dailyItinerary.first.morning,
        'Regenerated morning activity',
      );
    },
  );

  testWidgets(
    'SavedTripDetailsPage contains Edit option in AppBar and refreshes with regenerated plan',
    (tester) async {
      final mockRepo = MockSavedTripRepository();
      final mockTripPlannerRepo = MockTripPlannerRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savedTripRepositoryProvider.overrideWithValue(mockRepo),
            tripPlannerRepositoryProvider.overrideWithValue(
              mockTripPlannerRepo,
            ),
            savedTripsProvider.overrideWith(
              (ref) => Stream.value([initialTrip]),
            ),
            travelInterestsProvider.overrideWith(
              (ref) => Future.value([
                const TravelInterestModel(id: '1', name: 'Beach'),
              ]),
            ),
          ],
          child: MaterialApp(home: SavedTripDetailsPage(trip: initialTrip)),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial values on details page
      expect(find.text('Goa'), findsWidgets);
      expect(find.text('₹25000'), findsOneWidget);
      expect(find.text('A wonderful beach holiday in Goa.'), findsOneWidget);

      // Verify Edit icon exists in AppBar
      final editButton = find.byTooltip('Edit Trip');
      expect(editButton, findsOneWidget);

      // Tap Edit button to open EditTripPage
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verify EditTripPage opened
      expect(find.text('Edit Trip'), findsOneWidget);

      // Change budget
      final budgetField = find.widgetWithText(TextField, '25000');
      await tester.enterText(budgetField, '40000');
      await tester.pump();

      // Save
      final saveButton = find.widgetWithText(FilledButton, 'Save Changes');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify returned to SavedTripDetailsPage and shows updated budget and regenerated plan content
      expect(find.text('₹40000'), findsOneWidget);
      expect(find.text('Regenerated overview for Goa'), findsOneWidget);

      final morningActivity = find.text('Regenerated morning activity');
      await tester.scrollUntilVisible(morningActivity, 200);
      expect(morningActivity, findsOneWidget);
    },
  );

  test(
    'TravelInterestService returns default interests when unauthenticated without throwing permission errors',
    () async {
      final service = TravelInterestService();
      final interests = await service.getInterests();
      expect(interests, isNotEmpty);
      expect(interests.any((i) => i.name == 'Beach'), isTrue);
      expect(interests.any((i) => i.name == 'Adventure'), isTrue);
    },
  );
}
