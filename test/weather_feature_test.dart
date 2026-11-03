import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voyara/core/services/api_service.dart';
import 'package:voyara/features/home/data/models/daily_forecast_model.dart';
import 'package:voyara/features/home/data/models/destination_model.dart';
import 'package:voyara/features/home/data/models/weather_model.dart';
import 'package:voyara/features/home/data/repositories/weather_repository.dart';
import 'package:voyara/features/home/data/services/weather_service.dart';
import 'package:voyara/features/home/presentation/pages/destination_details_page.dart';
import 'package:voyara/features/home/providers/destination_details_provider.dart';
import 'package:voyara/features/home/providers/home_provider.dart';
import 'package:voyara/features/home/providers/review_provider.dart';
import 'package:voyara/features/home/providers/similar_provider.dart';
import 'package:voyara/features/home/data/models/nearby_result_model.dart';
import 'package:voyara/features/trip_planner/data/models/saved_trip_model.dart';
import 'package:voyara/features/trip_planner/presentation/pages/saved_trip_details_page.dart';
import 'package:voyara/features/trip_planner/providers/trip_weather_provider.dart';

class FakeWeatherService extends WeatherService {
  FakeWeatherService() : super(ApiService());

  int weatherCallCount = 0;
  int forecastCallCount = 0;
  bool shouldThrow = false;
  Map<String, dynamic>? customWeatherResponse;
  Map<String, dynamic>? customForecastResponse;

  @override
  Future<dynamic> getWeather({required double lat, required double lon}) async {
    weatherCallCount++;
    if (shouldThrow) {
      throw Exception('Simulated Weather API Failure');
    }
    return customWeatherResponse ??
        {
          'main': {'temp': 28.5, 'temp_min': 26.0, 'temp_max': 31.0},
          'weather': [
            {'main': 'Sunny', 'icon': '01d'},
          ],
        };
  }

  @override
  Future<dynamic> getForecast({
    required double lat,
    required double lon,
  }) async {
    forecastCallCount++;
    if (shouldThrow) {
      throw Exception('Simulated Forecast API Failure');
    }
    return customForecastResponse ??
        {
          'city': {'timezone': 0},
          'list': [
            {
              'dt': 1700000000,
              'main': {'temp': 20.0, 'temp_min': 18.0, 'temp_max': 22.0},
              'weather': [
                {'main': 'Clear', 'icon': '01d'},
              ],
            },
            {
              'dt': 1700010800,
              'main': {'temp': 25.0, 'temp_min': 24.0, 'temp_max': 27.0},
              'weather': [
                {'main': 'Clear', 'icon': '01d'},
              ],
            },
          ],
        };
  }
}

void main() {
  group('DailyForecastModel Parsing & Grouping Tests', () {
    test(
      'Groups 3-hour entries into calendar days and computes daily min/max',
      () {
        // Create sample forecast spanning 2 distinct days
        // Day 1: 2026-10-20 (Noon, Afternoon, Night)
        // Day 2: 2026-10-21 (Morning, Noon)
        final sampleJson = {
          'city': {'timezone': 19800}, // UTC +5:30 (IST)
          'list': [
            // 2026-10-20 06:30 UTC -> 12:00 IST
            {
              'dt':
                  DateTime.utc(2026, 10, 20, 6, 30).millisecondsSinceEpoch ~/
                  1000,
              'main': {'temp': 29.0, 'temp_min': 28.0, 'temp_max': 30.5},
              'weather': [
                {'main': 'Sunny', 'icon': '01d'},
              ],
            },
            // 2026-10-20 12:30 UTC -> 18:00 IST
            {
              'dt':
                  DateTime.utc(2026, 10, 20, 12, 30).millisecondsSinceEpoch ~/
                  1000,
              'main': {'temp': 24.0, 'temp_min': 23.5, 'temp_max': 25.0},
              'weather': [
                {'main': 'Clouds', 'icon': '02d'},
              ],
            },
            // 2026-10-21 03:30 UTC -> 09:00 IST
            {
              'dt':
                  DateTime.utc(2026, 10, 21, 3, 30).millisecondsSinceEpoch ~/
                  1000,
              'main': {'temp': 22.0, 'temp_min': 20.0, 'temp_max': 23.0},
              'weather': [
                {'main': 'Rain', 'icon': '10d'},
              ],
            },
            // 2026-10-21 06:30 UTC -> 12:00 IST
            {
              'dt':
                  DateTime.utc(2026, 10, 21, 6, 30).millisecondsSinceEpoch ~/
                  1000,
              'main': {'temp': 26.0, 'temp_min': 25.0, 'temp_max': 27.5},
              'weather': [
                {'main': 'Thunderstorm', 'icon': '11d'},
              ],
            },
          ],
        };

        final dailyList = DailyForecastModel.parseForecastList(sampleJson);

        expect(dailyList.length, 2);

        // Day 1 validation
        final day1 = dailyList[0];
        expect(day1.date.year, 2026);
        expect(day1.date.month, 10);
        expect(day1.date.day, 20);
        expect(day1.minTemp, 23.5);
        expect(day1.maxTemp, 30.5);
        // Entry closest to noon IST (12:00) is the Sunny entry
        expect(day1.condition, 'Sunny');
        expect(day1.icon, '01d');

        // Day 2 validation
        final day2 = dailyList[1];
        expect(day2.date.year, 2026);
        expect(day2.date.month, 10);
        expect(day2.date.day, 21);
        expect(day2.minTemp, 20.0);
        expect(day2.maxTemp, 27.5);
        // Entry at 12:00 IST is Thunderstorm
        expect(day2.condition, 'Thunderstorm');
        expect(day2.icon, '11d');
      },
    );

    test('Handles empty and malformed json gracefully', () {
      expect(DailyForecastModel.parseForecastList({}), isEmpty);
      expect(DailyForecastModel.parseForecastList({'list': []}), isEmpty);
      expect(
        DailyForecastModel.parseForecastList({
          'list': [null, 'invalid', {}],
        }),
        isEmpty,
      );
    });
  });

  group('WeatherRepository Caching & 30-Minute TTL Tests', () {
    test(
      'Caches current weather for 30 minutes and expires afterwards',
      () async {
        final fakeService = FakeWeatherService();
        DateTime currentTime = DateTime(2026, 10, 20, 10, 0);

        final repository = WeatherRepository(
          fakeService,
          clock: () => currentTime,
        );

        // 1. First call: fetches from service
        final w1 = await repository.getWeather(
          latitude: 28.61,
          longitude: 77.20,
        );
        expect(fakeService.weatherCallCount, 1);
        expect(w1.temperature, 28.5);
        expect(repository.isWeatherCached(28.61, 77.20), isTrue);

        // 2. Second call 15 minutes later (within 30m TTL): hits cache
        currentTime = currentTime.add(const Duration(minutes: 15));
        final w2 = await repository.getWeather(
          latitude: 28.61,
          longitude: 77.20,
        );
        expect(fakeService.weatherCallCount, 1); // No new network call
        expect(w2.temperature, 28.5);

        // 3. Third call 31 minutes after initial fetch: expired, re-fetches
        currentTime = DateTime(2026, 10, 20, 10, 31);
        final w3 = await repository.getWeather(
          latitude: 28.61,
          longitude: 77.20,
        );
        expect(fakeService.weatherCallCount, 2); // Re-fetched
        expect(w3.temperature, 28.5);

        // 4. Force refresh bypasses cache even within TTL
        currentTime = currentTime.add(const Duration(minutes: 2));
        await repository.getWeather(
          latitude: 28.61,
          longitude: 77.20,
          forceRefresh: true,
        );
        expect(fakeService.weatherCallCount, 3);
      },
    );

    test('Caches forecast for 30 minutes and expires afterwards', () async {
      final fakeService = FakeWeatherService();
      DateTime currentTime = DateTime(2026, 10, 20, 10, 0);

      final repository = WeatherRepository(
        fakeService,
        clock: () => currentTime,
      );

      // 1. Initial forecast fetch
      final f1 = await repository.getForecast(
        latitude: 28.61,
        longitude: 77.20,
      );
      expect(fakeService.forecastCallCount, 1);
      expect(f1, isNotEmpty);
      expect(repository.isForecastCached(28.61, 77.20), isTrue);

      // 2. Subsequent call within 30 min: uses cache
      currentTime = currentTime.add(const Duration(minutes: 20));
      await repository.getForecast(latitude: 28.61, longitude: 77.20);
      expect(fakeService.forecastCallCount, 1);

      // 3. Expired call after 31 min: re-fetches
      currentTime = currentTime.add(
        const Duration(minutes: 11),
      ); // 31 min total
      await repository.getForecast(latitude: 28.61, longitude: 77.20);
      expect(fakeService.forecastCallCount, 2);
    });
  });

  group('WeatherRepository Error Handling Tests', () {
    test('getWeather catches errors and returns unavailable model', () async {
      final fakeService = FakeWeatherService()..shouldThrow = true;
      final repository = WeatherRepository(fakeService);

      final result = await repository.getWeather(
        latitude: 10.0,
        longitude: 20.0,
      );

      expect(result.isAvailable, isFalse);
      expect(result.temperature, isNull);
      expect(result.condition, isNull);
    });

    test(
      'getForecast rethrows errors so Riverpod can enter error state',
      () async {
        final fakeService = FakeWeatherService()..shouldThrow = true;
        final repository = WeatherRepository(fakeService);

        expect(
          () => repository.getForecast(latitude: 10.0, longitude: 20.0),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  group('Trip-Date Weather Provider Logic Tests', () {
    test(
      'Trip starting 14 days in the future (beyond 5-day window) shows current destination weather without inventing forecast',
      () async {
        final fakeService = FakeWeatherService();
        final container = ProviderContainer(
          overrides: [weatherServiceProvider.overrideWithValue(fakeService)],
        );
        addTearDown(container.dispose);

        final futureTrip = SavedTripModel(
          id: 'trip-1',
          destination: 'Goa',
          latitude: 15.2993,
          longitude: 74.1240,
          startDate: DateTime.now().add(const Duration(days: 14)),
          days: 4,
          budget: 20000,
          travelers: 2,
          interests: const ['Beach'],
          overview: 'Trip to Goa',
          budgetSummary: 'Budget breakdown',
          dailyItinerary: const [],
          packingChecklist: const [],
          safetyTips: const [],
          localTips: const [],
          createdAt: DateTime.now(),
        );

        final state = await container.read(
          tripWeatherProvider(futureTrip).future,
        );

        expect(state.mode, TripWeatherMode.currentClimate);
        expect(state.currentWeather, isNotNull);
        expect(state.currentWeather!.isAvailable, isTrue);
        expect(state.matchingForecasts, isEmpty);
        expect(state.message, contains('beyond 5-day forecast window'));
      },
    );

    test(
      'Trip starting tomorrow overlaps 5-day forecast and displays live days',
      () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final tomorrowDate = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
        );

        final fakeService = FakeWeatherService()
          ..customForecastResponse = {
            'city': {'timezone': 0},
            'list': [
              {
                'dt':
                    tomorrowDate
                        .add(const Duration(hours: 12))
                        .millisecondsSinceEpoch ~/
                    1000,
                'main': {'temp': 27.0, 'temp_min': 24.0, 'temp_max': 30.0},
                'weather': [
                  {'main': 'Sunny', 'icon': '01d'},
                ],
              },
            ],
          };

        final container = ProviderContainer(
          overrides: [weatherServiceProvider.overrideWithValue(fakeService)],
        );
        addTearDown(container.dispose);

        final upcomingTrip = SavedTripModel(
          id: 'trip-2',
          destination: 'Manali',
          latitude: 32.2396,
          longitude: 77.1887,
          startDate: tomorrow,
          days: 3,
          budget: 15000,
          travelers: 2,
          interests: const ['Mountains'],
          overview: 'Trip to Manali',
          budgetSummary: 'Budget breakdown',
          dailyItinerary: const [],
          packingChecklist: const [],
          safetyTips: const [],
          localTips: const [],
          createdAt: DateTime.now(),
        );

        final state = await container.read(
          tripWeatherProvider(upcomingTrip).future,
        );

        expect(state.mode, TripWeatherMode.forecast);
        expect(state.matchingForecasts.length, 1);
        expect(state.matchingForecasts[0].condition, 'Sunny');
        expect(state.message, contains('Live 5-day forecast'));
      },
    );

    test('Past trip shows completed notice with current conditions', () async {
      final fakeService = FakeWeatherService();
      final container = ProviderContainer(
        overrides: [weatherServiceProvider.overrideWithValue(fakeService)],
      );
      addTearDown(container.dispose);

      final pastTrip = SavedTripModel(
        id: 'trip-past',
        destination: 'Jaipur',
        latitude: 26.9124,
        longitude: 75.7873,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        days: 3,
        budget: 10000,
        travelers: 1,
        interests: const ['Heritage'],
        overview: 'Trip to Jaipur',
        budgetSummary: 'Budget breakdown',
        dailyItinerary: const [],
        packingChecklist: const [],
        safetyTips: const [],
        localTips: const [],
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
      );

      final state = await container.read(tripWeatherProvider(pastTrip).future);

      expect(state.mode, TripWeatherMode.pastTrip);
      expect(state.message, contains('Trip completed'));
    });

    test(
      'Trip with invalid coordinates (0, 0) returns unavailable state',
      () async {
        final fakeService = FakeWeatherService();
        final container = ProviderContainer(
          overrides: [weatherServiceProvider.overrideWithValue(fakeService)],
        );
        addTearDown(container.dispose);

        final zeroCoordTrip = SavedTripModel(
          id: 'trip-0',
          destination: 'Unknown',
          latitude: 0,
          longitude: 0,
          startDate: DateTime.now().add(const Duration(days: 2)),
          days: 2,
          budget: 5000,
          travelers: 1,
          interests: const [],
          overview: '',
          budgetSummary: '',
          dailyItinerary: const [],
          packingChecklist: const [],
          safetyTips: const [],
          localTips: const [],
          createdAt: DateTime.now(),
        );

        final state = await container.read(
          tripWeatherProvider(zeroCoordTrip).future,
        );

        expect(state.mode, TripWeatherMode.unavailable);
        expect(state.isAvailable, isFalse);
      },
    );
  });

  group('Destination Details 5-Day Forecast Widget Smoke Tests', () {
    testWidgets('Renders 5-Day Forecast section below current weather card', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final sampleDestination = DestinationModel(
        id: 'dest-1',
        title: 'Taj Mahal',
        location: 'Agra, Uttar Pradesh',
        imageUrl: '',
        rating: 4.8,
        price: 50.0,
        description: 'Iconic marble monument',
        categories: const ['Monument'],
        includes: const [],
        reviews: const [],
        latitude: 27.1751,
        longitude: 78.0421,
      );

      final mockForecast = [
        DailyForecastModel(
          date: DateTime.now(),
          minTemp: 20.0,
          maxTemp: 32.0,
          condition: 'Sunny',
          icon: '01d',
        ),
        DailyForecastModel(
          date: DateTime.now().add(const Duration(days: 1)),
          minTemp: 21.0,
          maxTemp: 31.0,
          condition: 'Clouds',
          icon: '02d',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            destinationWeatherAsyncProvider(sampleDestination).overrideWith(
              (ref) => Future.value(
                const WeatherModel(
                  temperature: 30.5,
                  condition: 'Clear',
                  icon: '01d',
                  isAvailable: true,
                ),
              ),
            ),
            destinationForecastAsyncProvider(
              sampleDestination,
            ).overrideWith((ref) => Future.value(mockForecast)),
            destinationDescriptionAsyncProvider(sampleDestination).overrideWith(
              (ref) => Future.value('A famous historic marble monument.'),
            ),
            destinationImagesAsyncProvider(
              sampleDestination,
            ).overrideWith((ref) => Future.value([])),
            similarDestinationsProvider(
              sampleDestination,
            ).overrideWith((ref) => Future.value([])),
            nearbyPlacesProvider((
              lat: sampleDestination.latitude,
              lon: sampleDestination.longitude,
            )).overrideWith(
              (ref) => Future.value(
                const NearbyResultModel(destinations: [], usedRadius: 5000),
              ),
            ),
            nearbyHotelsProvider((
              lat: sampleDestination.latitude,
              lon: sampleDestination.longitude,
            )).overrideWith((ref) => Future.value([])),
            reviewsProvider(
              sampleDestination.id,
            ).overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            home: DestinationDetailsPage(destination: sampleDestination),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Current weather is preserved
      expect(find.text('30.5°C'), findsWidgets);
      expect(find.text('Clear'), findsWidgets);

      // 5-Day Forecast section is present
      expect(find.text('5-Day Forecast'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('32° / 20°'), findsOneWidget);
    });
  });

  group('Saved Trip Details Weather Card Widget Smoke Tests', () {
    testWidgets(
      'Renders Trip Weather section with live forecast on saved trip',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final trip = SavedTripModel(
          id: 'trip-widget-test',
          destination: 'Udaipur',
          latitude: 24.5854,
          longitude: 73.7125,
          startDate: tomorrow,
          days: 3,
          budget: 25000,
          travelers: 2,
          interests: const ['Palace'],
          overview: 'Romantic city of lakes',
          budgetSummary: '₹25,000 for 3 days',
          dailyItinerary: const [],
          packingChecklist: const [],
          safetyTips: const [],
          localTips: const [],
          createdAt: DateTime.now(),
        );

        final tripState = TripWeatherState(
          mode: TripWeatherMode.forecast,
          currentWeather: const WeatherModel(
            temperature: 29.0,
            condition: 'Clear',
            isAvailable: true,
          ),
          matchingForecasts: [
            DailyForecastModel(
              date: tomorrow,
              minTemp: 22.0,
              maxTemp: 31.0,
              condition: 'Clear',
              icon: '01d',
            ),
          ],
          message: 'Live 5-day forecast for 1 of 3 trip days.',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tripWeatherProvider(
                trip,
              ).overrideWith((ref) => Future.value(tripState)),
            ],
            child: MaterialApp(home: SavedTripDetailsPage(trip: trip)),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Trip Weather'), findsOneWidget);
        expect(
          find.text('Live 5-day forecast for 1 of 3 trip days.'),
          findsOneWidget,
        );
        expect(find.text('31° / 22°'), findsOneWidget);
      },
    );
  });
}
