import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:voyara/core/services/api_service.dart';
import 'package:voyara/core/utils/map_launcher.dart';
import 'package:voyara/features/home/data/models/route_model.dart';
import 'package:voyara/features/home/data/repositories/geoapify_repository.dart';
import 'package:voyara/features/home/data/services/geoapify_service.dart';
import 'package:voyara/features/home/presentation/widgets/destination_map.dart';
import 'package:voyara/features/home/providers/home_provider.dart';
import 'package:voyara/features/trip_planner/data/models/saved_trip_model.dart';
import 'package:voyara/features/trip_planner/presentation/pages/saved_trip_details_page.dart';
import 'package:voyara/features/trip_planner/providers/saved_trip_provider.dart';
import 'package:voyara/features/trip_planner/data/repositories/saved_trip_repository.dart';

class MockSavedTripRepository implements SavedTripRepository {
  @override
  Future<void> saveTrip(SavedTripModel trip) async {}
  @override
  Future<void> updateTrip(SavedTripModel trip) async {}
  @override
  Stream<List<SavedTripModel>> getTrips() => Stream.value([]);
  @override
  Future<void> deleteTrip(String id) async {}
}

class FakeApiService implements ApiService {
  Map<String, dynamic>? mockResponse;
  String? lastRequestedUrl;
  bool shouldThrow = false;

  @override
  Future<dynamic> get(String url) async {
    lastRequestedUrl = url;
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return mockResponse ?? {'features': []};
  }
}

void main() {
  group('RouteModel Unit Tests', () {
    test('Parses LineString GeoJSON correctly and formats distance and duration', () {
      final json = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              'coordinates': [
                [77.23296, 28.614239],
                [77.245904, 28.593539],
              ],
            },
            'properties': {
              'mode': 'drive',
              'distance': 3450.0,
              'time': 480.0,
            },
          }
        ],
      };

      final route = RouteModel.fromGeoapify(json);

      expect(route.points.length, 2);
      expect(route.points[0].latitude, 28.614239);
      expect(route.points[0].longitude, 77.23296);
      expect(route.points[1].latitude, 28.593539);
      expect(route.points[1].longitude, 77.245904);
      expect(route.distanceMeters, 3450.0);
      expect(route.durationSeconds, 480.0);
      expect(route.formattedDistance, '3.5 km');
      expect(route.formattedDuration, '8 mins');
    });

    test('Parses MultiLineString GeoJSON correctly', () {
      final json = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'MultiLineString',
              'coordinates': [
                [
                  [77.10, 28.50],
                  [77.15, 28.55],
                ],
                [
                  [77.15, 28.55],
                  [77.20, 28.60],
                ]
              ],
            },
            'properties': {
              'distance': 750.0,
              'time': 4500.0,
            },
          }
        ],
      };

      final route = RouteModel.fromGeoapify(json);

      expect(route.points.length, 4);
      expect(route.formattedDistance, '750 m');
      expect(route.formattedDuration, '1 hr 15 min');
    });

    test('Handles empty or invalid features gracefully', () {
      final empty = RouteModel.fromGeoapify({'features': []});
      expect(empty.points, isEmpty);
      expect(empty.distanceMeters, 0.0);
      expect(empty.durationSeconds, 0.0);
      expect(empty.formattedDistance, '0 m');
      expect(empty.formattedDuration, '0 mins');
    });
  });

  group('GeoapifyService & GeoapifyRepository Route Tests', () {
    test('GeoapifyService.getRoute formats correct query URL', () async {
      final fakeApi = FakeApiService();
      final service = GeoapifyService(fakeApi);

      await service.getRoute(
        startLat: 28.61,
        startLon: 77.23,
        endLat: 28.59,
        endLon: 77.24,
      );

      expect(fakeApi.lastRequestedUrl, isNotNull);
      expect(fakeApi.lastRequestedUrl, contains('https://api.geoapify.com/v1/routing'));
      expect(fakeApi.lastRequestedUrl, contains('waypoints=28.61,77.23|28.59,77.24'));
      expect(fakeApi.lastRequestedUrl, contains('mode=drive'));
    });

    test('GeoapifyRepository.getRoute returns RouteModel on success', () async {
      final fakeApi = FakeApiService();
      fakeApi.mockResponse = {
        'features': [
          {
            'geometry': {
              'type': 'LineString',
              'coordinates': [
                [77.20, 28.60],
                [77.25, 28.65],
              ],
            },
            'properties': {
              'distance': 5000.0,
              'time': 600.0,
            },
          }
        ],
      };

      final repo = GeoapifyRepository(GeoapifyService(fakeApi));
      final route = await repo.getRoute(
        startLat: 28.60,
        startLon: 77.20,
        endLat: 28.65,
        endLon: 77.25,
      );

      expect(route, isNotNull);
      expect(route!.points.length, 2);
      expect(route.formattedDistance, '5.0 km');
    });

    test('GeoapifyRepository.getRoute handles API error returning null without throwing', () async {
      final fakeApi = FakeApiService();
      fakeApi.shouldThrow = true;

      final repo = GeoapifyRepository(GeoapifyService(fakeApi));
      final route = await repo.getRoute(
        startLat: 28.60,
        startLon: 77.20,
        endLat: 28.65,
        endLon: 77.25,
      );

      expect(route, isNull);
    });

    test('GeoapifyRepository.getRoute validates coordinates and rejects invalid/zero inputs', () async {
      final fakeApi = FakeApiService();
      final repo = GeoapifyRepository(GeoapifyService(fakeApi));

      // Test origin (0,0)
      final routeZero = await repo.getRoute(
        startLat: 0.0,
        startLon: 0.0,
        endLat: 28.65,
        endLon: 77.25,
      );
      expect(routeZero, isNull);

      // Test out of bounds latitude
      final routeOutOfBounds = await repo.getRoute(
        startLat: 95.0,
        startLon: 77.20,
        endLat: 28.65,
        endLon: 77.25,
      );
      expect(routeOutOfBounds, isNull);
    });

    test('GeoapifyRepository.getRoute handles API error response payload gracefully', () async {
      final fakeApi = FakeApiService();
      fakeApi.mockResponse = {
        'statusCode': 400,
        'error': 'Bad Request',
        'message': 'No route found between points',
      };

      final repo = GeoapifyRepository(GeoapifyService(fakeApi));
      final route = await repo.getRoute(
        startLat: 28.60,
        startLon: 77.20,
        endLat: 28.65,
        endLon: 77.25,
      );

      expect(route, isNull);
    });
  });

  group('DestinationMap Widget Tests', () {
    testWidgets('Renders destination marker without errors when user location is null', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DestinationMap(
                latitude: 28.614239,
                longitude: 77.23296,
                showUserLocation: false,
                showRoute: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DestinationMap), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsWidgets);
    });

    testWidgets('Renders user marker and re-center controls when user location is provided', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DestinationMap(
                latitude: 28.614239,
                longitude: 77.23296,
                userLatitude: 28.5355,
                userLongitude: 77.3910,
                showUserLocation: true,
                showRoute: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.my_location), findsWidgets);
      expect(find.byIcon(Icons.location_on), findsWidgets);
    });

    testWidgets('Displays route chip and fit-route button when route is loaded', (tester) async {
      const mockRoute = RouteModel(
        points: [
          LatLng(28.5355, 77.3910),
          LatLng(28.6142, 77.2329),
        ],
        distanceMeters: 14200,
        durationSeconds: 1500,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routeFutureProvider.overrideWith((ref, query) => Future.value(mockRoute)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DestinationMap(
                latitude: 28.6142,
                longitude: 77.2329,
                userLatitude: 28.5355,
                userLongitude: 77.3910,
                showUserLocation: true,
                showRoute: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Est. 14.2 km • 25 mins · No live traffic'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
      expect(find.byIcon(Icons.route), findsOneWidget);
      expect(find.textContaining('OpenStreetMap/Geoapify'), findsOneWidget);
    });

    testWidgets('Displays retry chip when route fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routeFutureProvider.overrideWith((ref, query) => Future.value(null)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DestinationMap(
                latitude: 28.6142,
                longitude: 77.2329,
                userLatitude: 28.5355,
                userLongitude: 77.3910,
                showUserLocation: true,
                showRoute: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Route unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('SavedTripDetailsPage Map & Directions Tests', () {
    testWidgets('Renders DestinationMap and Get Directions button for saved trip with coordinates', (tester) async {
      final tripWithCoords = SavedTripModel(
        id: 'trip_delhi',
        destination: 'Delhi',
        latitude: 28.614239,
        longitude: 77.23296,
        startDate: DateTime(2026, 11, 10),
        days: 3,
        budget: 15000,
        travelers: 2,
        interests: ['History'],
        overview: 'Historic trip to Delhi.',
        budgetSummary: 'Budget is ₹15,000.',
        dailyItinerary: [],
        packingChecklist: [],
        safetyTips: [],
        localTips: [],
        createdAt: DateTime(2026, 10, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savedTripRepositoryProvider.overrideWithValue(MockSavedTripRepository()),
            savedTripsProvider.overrideWith((ref) => Stream.value([tripWithCoords])),
          ],
          child: MaterialApp(
            home: SavedTripDetailsPage(trip: tripWithCoords),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to Location & Map section in ListView
      await tester.scrollUntilVisible(find.text('Location & Map'), 100);
      await tester.pumpAndSettle();

      // Verify DestinationMap and Directions button exist
      expect(find.text('Location & Map'), findsOneWidget);
      expect(find.byType(DestinationMap), findsOneWidget);
      expect(find.text('Get Directions in Google Maps'), findsOneWidget);
      expect(find.text('Turn-by-turn navigation • Live traffic'), findsOneWidget);
    });
  });

  group('MapLauncher URL Construction Tests', () {
    test('buildDirectionsUri includes coordinates and travelmode=driving', () {
      final uri = MapLauncher.buildDirectionsUri(
        destinationLatitude: 28.614239,
        destinationLongitude: 77.23296,
        originLatitude: 28.5355,
        originLongitude: 77.3910,
      );

      final url = uri.toString();
      expect(url, contains('https://www.google.com/maps/dir/?api=1'));
      expect(url, contains('destination=28.614239,77.23296'));
      expect(url, contains('origin=28.5355,77.391'));
      expect(url, contains('travelmode=driving'));
    });
  });
}
