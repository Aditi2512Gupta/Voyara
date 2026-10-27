import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/models/daily_forecast_model.dart';
import '../../home/data/models/weather_model.dart';
import '../../home/providers/home_provider.dart';
import '../data/models/saved_trip_model.dart';

enum TripWeatherMode {
  forecast,
  currentClimate,
  pastTrip,
  unavailable,
}

class TripWeatherState {
  final TripWeatherMode mode;
  final WeatherModel? currentWeather;
  final List<DailyForecastModel> matchingForecasts;
  final String message;

  const TripWeatherState({
    required this.mode,
    this.currentWeather,
    this.matchingForecasts = const [],
    this.message = '',
  });

  bool get isAvailable =>
      mode != TripWeatherMode.unavailable &&
      ((mode == TripWeatherMode.forecast && matchingForecasts.isNotEmpty) ||
          (currentWeather != null && currentWeather!.isAvailable));
}

final tripWeatherProvider =
    FutureProvider.family.autoDispose<TripWeatherState, SavedTripModel>((
  ref,
  trip,
) async {
  if (trip.latitude == 0 && trip.longitude == 0) {
    return const TripWeatherState(
      mode: TripWeatherMode.unavailable,
      message: 'Coordinates unavailable for this trip destination.',
    );
  }

  final weatherRepo = ref.read(weatherRepositoryProvider);

  final currentWeather = await weatherRepo.getWeather(
    latitude: trip.latitude,
    longitude: trip.longitude,
  );

  List<DailyForecastModel> forecast = [];
  try {
    forecast = await weatherRepo.getForecast(
      latitude: trip.latitude,
      longitude: trip.longitude,
    );
  } catch (_) {
    forecast = [];
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tripStart = DateTime(
    trip.startDate.year,
    trip.startDate.month,
    trip.startDate.day,
  );
  final tripDays = trip.days > 0 ? trip.days : 1;
  final tripEnd = tripStart.add(Duration(days: tripDays - 1));

  // 1. Past trip check
  if (tripEnd.isBefore(today)) {
    if (!currentWeather.isAvailable) {
      return const TripWeatherState(
        mode: TripWeatherMode.unavailable,
        message: 'Weather data unavailable.',
      );
    }
    return TripWeatherState(
      mode: TripWeatherMode.pastTrip,
      currentWeather: currentWeather,
      message: 'Trip completed. Showing current conditions at destination.',
    );
  }

  // 2. Overlapping live forecast check
  final matching = forecast.where((f) {
    final fDate = DateTime(f.date.year, f.date.month, f.date.day);
    return !fDate.isBefore(tripStart) && !fDate.isAfter(tripEnd);
  }).toList();

  if (matching.isNotEmpty) {
    return TripWeatherState(
      mode: TripWeatherMode.forecast,
      currentWeather: currentWeather,
      matchingForecasts: matching,
      message:
          'Live 5-day forecast for ${matching.length} of $tripDays trip day${tripDays == 1 ? '' : 's'}.',
    );
  }

  // 3. Beyond 5-day forecast window
  if (!currentWeather.isAvailable) {
    return const TripWeatherState(
      mode: TripWeatherMode.unavailable,
      message: 'Weather data unavailable.',
    );
  }

  final formattedDate =
      "${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}";
  return TripWeatherState(
    mode: TripWeatherMode.currentClimate,
    currentWeather: currentWeather,
    message:
        'Trip starts on $formattedDate (beyond 5-day forecast window). Showing current conditions at destination.',
  );
});
