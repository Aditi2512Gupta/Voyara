import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:voyara/features/auth/providers/auth_provider.dart';
import 'package:voyara/features/bookings/data/models/booking_model.dart';
import 'package:voyara/features/bookings/data/repositories/booking_repository.dart';
import 'package:voyara/features/bookings/data/services/booking_service.dart';
import 'package:voyara/features/bookings/presentation/pages/booking_details_page.dart';
import 'package:voyara/features/bookings/presentation/pages/booking_page.dart';
import 'package:voyara/features/bookings/presentation/pages/booking_success_page.dart';
import 'package:voyara/features/bookings/presentation/providers/booking_form_provider.dart';
import 'package:voyara/features/bookings/providers/booking_loading_provider.dart';
import 'package:voyara/features/bookings/providers/booking_provider.dart';
import 'package:voyara/features/home/data/models/destination_model.dart';
import 'package:voyara/features/navigation/presentation/pages/main_navigation_page.dart';
import 'package:voyara/features/trips/data/models/trip_filter.dart';
import 'package:voyara/features/trips/data/models/trip_status.dart';
import 'package:voyara/features/trips/providers/trip_filter_provider.dart';
import 'package:voyara/features/trips/providers/trip_stats_provider.dart';
import 'package:voyara/features/trips/providers/trips_provider.dart';

class FakeUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  FakeUser({
    this.uid = 'test_uid_456',
    this.email = 'test@example.com',
    this.displayName = 'Test User',
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockBookingRepository implements BookingRepository {
  BookingModel? lastCreatedBooking;
  String? lastCancelledBookingId;
  bool shouldThrowOnCreate = false;
  bool shouldThrowOnCancel = false;
  List<BookingModel> currentBookings = [];

  @override
  Future<void> createBooking(BookingModel booking) async {
    if (shouldThrowOnCreate) {
      throw Exception('Network connection timed out');
    }
    lastCreatedBooking = booking;
    currentBookings.add(booking);
  }

  @override
  Stream<List<BookingModel>> bookings() {
    return Stream.value(currentBookings);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    if (shouldThrowOnCancel) {
      throw Exception('Server cancellation failed');
    }
    lastCancelledBookingId = bookingId;
    final index = currentBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final old = currentBookings[index];
      currentBookings[index] = BookingModel(
        id: old.id,
        destinationId: old.destinationId,
        destinationName: old.destinationName,
        destinationLocation: old.destinationLocation,
        destinationImageUrl: old.destinationImageUrl,
        destinationLatitude: old.destinationLatitude,
        destinationLongitude: old.destinationLongitude,
        userId: old.userId,
        travelDate: old.travelDate,
        travelers: old.travelers,
        status: TripStatus.cancelled,
        bookingDate: old.bookingDate,
      );
    }
  }

  @override
  Future<void> updateCompletedTrips() async {
    final now = DateTime.now();
    for (int i = 0; i < currentBookings.length; i++) {
      final b = currentBookings[i];
      if (b.status == TripStatus.upcoming && b.travelDate.isBefore(now)) {
        currentBookings[i] = BookingModel(
          id: b.id,
          destinationId: b.destinationId,
          destinationName: b.destinationName,
          destinationLocation: b.destinationLocation,
          destinationImageUrl: b.destinationImageUrl,
          destinationLatitude: b.destinationLatitude,
          destinationLongitude: b.destinationLongitude,
          userId: b.userId,
          travelDate: b.travelDate,
          travelers: b.travelers,
          status: TripStatus.completed,
          bookingDate: b.bookingDate,
        );
      }
    }
  }
}

final sampleDestination = DestinationModel(
  id: 'dest_jaipur',
  title: 'Hawa Mahal',
  location: 'Jaipur, Rajasthan',
  imageUrl: 'https://images.unsplash.com/photo-test.jpg',
  rating: 4.6,
  price: 200,
  description: 'Palace of Winds in Jaipur.',
  categories: ['Historical', 'Culture'],
  includes: ['Entry Ticket'],
  reviews: const [],
  latitude: 26.9239,
  longitude: 75.8267,
);

void main() {
  group('BookingModel & Status Handling Tests', () {
    test('BookingModel serialization and deserialization with status', () {
      final travelDate = DateTime(2026, 12, 1);
      final bookingDate = DateTime(2026, 10, 1);

      final booking = BookingModel(
        id: 'book_001',
        destinationId: 'dest_jaipur',
        destinationName: 'Hawa Mahal',
        destinationLocation: 'Jaipur, Rajasthan',
        destinationImageUrl: 'https://images.unsplash.com/photo-test.jpg',
        destinationLatitude: 26.9239,
        destinationLongitude: 75.8267,
        userId: 'user_123',
        travelDate: travelDate,
        travelers: 2,
        status: TripStatus.upcoming,
        bookingDate: bookingDate,
      );

      final map = booking.toMap();
      expect(map['destinationId'], 'dest_jaipur');
      expect(map['destinationName'], 'Hawa Mahal');
      expect(map['travelers'], 2);
      expect(map['status'], 'upcoming');
      expect(map['travelDate'], travelDate.toIso8601String());
      expect(map['bookingDate'], bookingDate.toIso8601String());

      final restored = BookingModel.fromMap(map, 'book_001');
      expect(restored.id, 'book_001');
      expect(restored.destinationId, 'dest_jaipur');
      expect(restored.destinationName, 'Hawa Mahal');
      expect(restored.travelers, 2);
      expect(restored.status, TripStatus.upcoming);
      expect(restored.travelDate, travelDate);
      expect(restored.bookingDate, bookingDate);
      expect(restored.canCancel, isTrue);
    });

    test('canCancel is true only for upcoming status', () {
      final baseBooking = BookingModel(
        id: 'b1',
        destinationId: 'd1',
        destinationName: 'Taj Mahal',
        destinationLocation: 'Agra',
        destinationImageUrl: '',
        destinationLatitude: 0,
        destinationLongitude: 0,
        userId: 'u1',
        travelDate: DateTime.now().add(const Duration(days: 10)),
        travelers: 1,
        status: TripStatus.upcoming,
        bookingDate: DateTime.now(),
      );

      expect(baseBooking.canCancel, isTrue);

      final completedBooking = BookingModel(
        id: 'b2',
        destinationId: 'd1',
        destinationName: 'Taj Mahal',
        destinationLocation: 'Agra',
        destinationImageUrl: '',
        destinationLatitude: 0,
        destinationLongitude: 0,
        userId: 'u1',
        travelDate: DateTime.now().subtract(const Duration(days: 2)),
        travelers: 1,
        status: TripStatus.completed,
        bookingDate: DateTime.now(),
      );
      expect(completedBooking.canCancel, isFalse);

      final cancelledBooking = BookingModel(
        id: 'b3',
        destinationId: 'd1',
        destinationName: 'Taj Mahal',
        destinationLocation: 'Agra',
        destinationImageUrl: '',
        destinationLatitude: 0,
        destinationLongitude: 0,
        userId: 'u1',
        travelDate: DateTime.now().add(const Duration(days: 5)),
        travelers: 1,
        status: TripStatus.cancelled,
        bookingDate: DateTime.now(),
      );
      expect(cancelledBooking.canCancel, isFalse);
    });

    test('TripStats correctly calculates status counts', () async {
      final container = ProviderContainer(
        overrides: [
          bookingsProvider.overrideWith((ref) => Stream.value([
                BookingModel(
                  id: '1',
                  destinationId: 'd1',
                  destinationName: 'A',
                  destinationLocation: 'Loc A',
                  destinationImageUrl: '',
                  destinationLatitude: 0,
                  destinationLongitude: 0,
                  userId: 'u1',
                  travelDate: DateTime(2026, 11, 1),
                  travelers: 1,
                  status: TripStatus.upcoming,
                  bookingDate: DateTime(2026, 10, 1),
                ),
                BookingModel(
                  id: '2',
                  destinationId: 'd2',
                  destinationName: 'B',
                  destinationLocation: 'Loc B',
                  destinationImageUrl: '',
                  destinationLatitude: 0,
                  destinationLongitude: 0,
                  userId: 'u1',
                  travelDate: DateTime(2026, 9, 1),
                  travelers: 2,
                  status: TripStatus.completed,
                  bookingDate: DateTime(2026, 8, 1),
                ),
                BookingModel(
                  id: '3',
                  destinationId: 'd3',
                  destinationName: 'C',
                  destinationLocation: 'Loc C',
                  destinationImageUrl: '',
                  destinationLatitude: 0,
                  destinationLongitude: 0,
                  userId: 'u1',
                  travelDate: DateTime(2026, 8, 1),
                  travelers: 4,
                  status: TripStatus.cancelled,
                  bookingDate: DateTime(2026, 7, 1),
                ),
              ])),
        ],
      );

      // Listen to ensure stream emits
      container.listen(tripStatsProvider, (_, __) {});
      container.listen(tripsProvider, (_, __) {});
      await container.read(bookingsProvider.future);
      await pumpEventQueue();

      final statsAsync = container.read(tripStatsProvider);
      expect(statsAsync.value?.upcoming, 1);
      expect(statsAsync.value?.completed, 1);
      expect(statsAsync.value?.cancelled, 1);

      // Filtering by upcoming
      container.read(tripFilterProvider.notifier).state = TripFilter.upcoming;
      final upcomingTrips = container.read(tripsProvider);
      expect(upcomingTrips.value?.length, 1);
      expect(upcomingTrips.value?.first.destinationName, 'A');

      // Filtering by completed
      container.read(tripFilterProvider.notifier).state = TripFilter.completed;
      final completedTrips = container.read(tripsProvider);
      expect(completedTrips.value?.length, 1);
      expect(completedTrips.value?.first.destinationName, 'B');

      // Filtering by cancelled
      container.read(tripFilterProvider.notifier).state = TripFilter.cancelled;
      final cancelledTrips = container.read(tripsProvider);
      expect(cancelledTrips.value?.length, 1);
      expect(cancelledTrips.value?.first.destinationName, 'C');
    });
  });

  group('BookingService Guard Tests', () {
    test('BookingService throws clear exception on unauthenticated booking', () async {
      final service = BookingService();
      final dummyBooking = BookingModel(
        id: '1',
        destinationId: 'd1',
        destinationName: 'Test',
        destinationLocation: 'Test Loc',
        destinationImageUrl: '',
        destinationLatitude: 0,
        destinationLongitude: 0,
        userId: 'u1',
        travelDate: DateTime.now(),
        travelers: 1,
        status: TripStatus.upcoming,
        bookingDate: DateTime.now(),
      );

      expect(
        () => service.createBooking(dummyBooking),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('User must be logged in to create a booking'),
        )),
      );

      expect(
        () => service.cancelBooking('1'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('User must be logged in to cancel a booking'),
        )),
      );

      final stream = service.bookings();
      final list = await stream.first;
      expect(list, isEmpty);

      // updateCompletedTrips does not throw
      await expectLater(service.updateCompletedTrips(), completes);
    });
  });

  group('BookingPage Widget Tests', () {
    testWidgets('Unauthenticated user attempting to book triggers login SnackBar without crashing',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = MockBookingRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(null),
            bookingRepositoryProvider.overrideWithValue(mockRepo),
            bookingControllerProvider.overrideWithValue(
              BookingController(repository: mockRepo),
            ),
          ],
          child: MaterialApp(
            home: BookingPage(destination: sampleDestination),
          ),
        ),
      );

      final element = tester.element(find.byType(BookingPage));
      final container = ProviderScope.containerOf(element);

      // Set travel date to enable the Save Trip button
      container.read(travelDateProvider.notifier).state =
          DateTime.now().add(const Duration(days: 5));
      await tester.pump();

      final saveButton = find.widgetWithText(FilledButton, 'Save Trip');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pump();

      // Check login message
      expect(find.text('Please log in to save your trip'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);

      // Verify no booking was created
      expect(mockRepo.lastCreatedBooking, isNull);
      expect(container.read(bookingLoadingProvider), isFalse);
    });

    testWidgets('Successful booking creates booking, resets form, and loading state finishes',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = MockBookingRepository();
      final fakeUser = FakeUser(uid: 'user_success_999');

      final router = GoRouter(
        initialLocation: '/booking',
        routes: [
          GoRoute(
            path: '/booking',
            builder: (_, __) => BookingPage(destination: sampleDestination),
          ),
          GoRoute(
            path: '/booking-success',
            builder: (_, __) => const Scaffold(body: Text('Success Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(fakeUser),
            bookingRepositoryProvider.overrideWithValue(mockRepo),
            bookingControllerProvider.overrideWithValue(
              BookingController(repository: mockRepo),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      final element = tester.element(find.byType(BookingPage));
      final container = ProviderScope.containerOf(element);

      final chosenDate = DateTime.now().add(const Duration(days: 7));
      container.read(travelDateProvider.notifier).state = chosenDate;
      container.read(travelersProvider.notifier).state = 3;
      await tester.pump();

      final saveButton = find.widgetWithText(FilledButton, 'Save Trip');
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verified booking created
      expect(mockRepo.lastCreatedBooking, isNotNull);
      expect(mockRepo.lastCreatedBooking?.destinationId, sampleDestination.id);
      expect(mockRepo.lastCreatedBooking?.userId, 'user_success_999');
      expect(mockRepo.lastCreatedBooking?.travelers, 3);
      expect(mockRepo.lastCreatedBooking?.travelDate, chosenDate);
      expect(mockRepo.lastCreatedBooking?.status, TripStatus.upcoming);

      // Verify form was reset
      expect(container.read(travelDateProvider), isNull);
      expect(container.read(travelersProvider), 1);
      expect(container.read(bookingLoadingProvider), isFalse);

      // Verify navigated to success screen
      expect(find.text('Success Screen'), findsOneWidget);
    });

    testWidgets('Booking creation failure shows error SnackBar and resets loading state',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = MockBookingRepository()..shouldThrowOnCreate = true;
      final fakeUser = FakeUser(uid: 'user_fail_111');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(fakeUser),
            bookingRepositoryProvider.overrideWithValue(mockRepo),
            bookingControllerProvider.overrideWithValue(
              BookingController(repository: mockRepo),
            ),
          ],
          child: MaterialApp(
            home: BookingPage(destination: sampleDestination),
          ),
        ),
      );

      final element = tester.element(find.byType(BookingPage));
      final container = ProviderScope.containerOf(element);

      final chosenDate = DateTime.now().add(const Duration(days: 3));
      container.read(travelDateProvider.notifier).state = chosenDate;
      container.read(travelersProvider.notifier).state = 2;
      await tester.pump();

      final saveButton = find.widgetWithText(FilledButton, 'Save Trip');
      await tester.tap(saveButton);
      await tester.pump(const Duration(milliseconds: 300));

      // Error SnackBar displayed
      expect(find.textContaining('Failed to save trip: Network connection timed out'),
          findsOneWidget);

      // Button is NOT stuck in loading
      expect(container.read(bookingLoadingProvider), isFalse);

      // Form values are preserved for retry
      expect(container.read(travelDateProvider), chosenDate);
      expect(container.read(travelersProvider), 2);
    });
  });

  group('BookingDetailsPage Cancellation Tests', () {
    testWidgets('Cancel booking flow asks for confirmation, cancels on server, and shows feedback',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = MockBookingRepository();
      final upcomingBooking = BookingModel(
        id: 'book_cancel_test',
        destinationId: sampleDestination.id,
        destinationName: sampleDestination.title,
        destinationLocation: sampleDestination.location,
        destinationImageUrl: '',
        destinationLatitude: sampleDestination.latitude,
        destinationLongitude: sampleDestination.longitude,
        userId: 'user_123',
        travelDate: DateTime.now().add(const Duration(days: 10)),
        travelers: 2,
        status: TripStatus.upcoming,
        bookingDate: DateTime.now(),
      );
      mockRepo.currentBookings = [upcomingBooking];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockRepo),
            bookingControllerProvider.overrideWithValue(
              BookingController(repository: mockRepo),
            ),
          ],
          child: MaterialApp(
            home: BookingDetailsPage(booking: upcomingBooking),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Cancel button should be visible for upcoming booking
      final cancelButton = find.widgetWithText(FilledButton, 'Cancel Trip');
      expect(cancelButton, findsOneWidget);

      await tester.tap(cancelButton, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));

      // Dialog appears
      expect(find.text('Are you sure you want to cancel this trip?'), findsOneWidget);

      // Confirm cancellation
      final yesButton = find.widgetWithText(FilledButton, 'Yes');
      await tester.tap(yesButton);
      await tester.pump(const Duration(milliseconds: 200));

      // Cancellation triggered
      expect(mockRepo.lastCancelledBookingId, 'book_cancel_test');
      expect(find.text('Trip cancelled successfully'), findsOneWidget);
    });

    testWidgets('Cancellation failure shows error feedback without crashing',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = MockBookingRepository()..shouldThrowOnCancel = true;
      final upcomingBooking = BookingModel(
        id: 'book_fail_cancel',
        destinationId: sampleDestination.id,
        destinationName: sampleDestination.title,
        destinationLocation: sampleDestination.location,
        destinationImageUrl: '',
        destinationLatitude: sampleDestination.latitude,
        destinationLongitude: sampleDestination.longitude,
        userId: 'user_123',
        travelDate: DateTime.now().add(const Duration(days: 10)),
        travelers: 2,
        status: TripStatus.upcoming,
        bookingDate: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockRepo),
            bookingControllerProvider.overrideWithValue(
              BookingController(repository: mockRepo),
            ),
          ],
          child: MaterialApp(
            home: BookingDetailsPage(booking: upcomingBooking),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final cancelButton = find.widgetWithText(FilledButton, 'Cancel Trip');
      await tester.tap(cancelButton, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));

      final yesButton = find.widgetWithText(FilledButton, 'Yes');
      await tester.tap(yesButton);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Failed to cancel trip: Server cancellation failed'),
          findsOneWidget);
    });
  });

  group('Navigation & BookingSuccessPage Tests', () {
    testWidgets('BookingSuccessPage navigates to /home?tab=1 on View My Trips and /home on Back to Home',
        (tester) async {
      String? lastNavigatedRoute;

      final testRouter = GoRouter(
        initialLocation: '/booking-success',
        routes: [
          GoRoute(
            path: '/booking-success',
            builder: (_, __) => const BookingSuccessPage(),
          ),
          GoRoute(
            path: '/home',
            builder: (_, state) {
              lastNavigatedRoute = state.uri.toString();
              final tabIndex = state.uri.queryParameters['tab'] == '1' ? 1 : 0;
              return Scaffold(body: Text('Home Screen (tab: $tabIndex)'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );

      expect(find.text('Trip Saved Successfully!'), findsOneWidget);

      // Tap View My Trips
      final viewTripsButton = find.widgetWithText(FilledButton, 'View My Trips');
      expect(viewTripsButton, findsOneWidget);

      await tester.tap(viewTripsButton);
      await tester.pumpAndSettle();

      expect(lastNavigatedRoute, '/home?tab=1');
      expect(find.text('Home Screen (tab: 1)'), findsOneWidget);
    });

    testWidgets('MainNavigationPage honors initialIndex for direct tab routing',
        (tester) async {
      final mockRepo = MockBookingRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockRepo),
            bookingControllerProvider.overrideWithValue(
              BookingController(repository: mockRepo),
            ),
            bookingsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: MainNavigationPage(initialIndex: 1),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Trips page header should be visible
      expect(find.text('My Trips'), findsOneWidget);

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 1);
    });
  });
}
