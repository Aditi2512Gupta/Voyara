import '../models/daily_forecast_model.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class CachedWeatherEntry<T> {
  final T data;
  final DateTime timestamp;

  CachedWeatherEntry({required this.data, required this.timestamp});

  bool isExpired({required Duration ttl, required DateTime now}) {
    return now.difference(timestamp) >= ttl;
  }
}

class WeatherRepository {
  WeatherRepository(this._service, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final WeatherService _service;
  final DateTime Function() _clock;

  static const Duration cacheTtl = Duration(minutes: 30);

  final Map<String, CachedWeatherEntry<WeatherModel>> _weatherCache = {};
  final Map<String, CachedWeatherEntry<List<DailyForecastModel>>>
  _forecastCache = {};

  String _cacheKey(double lat, double lon) =>
      "${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}";

  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final key = _cacheKey(latitude, longitude);

    if (!forceRefresh && _weatherCache.containsKey(key)) {
      final entry = _weatherCache[key]!;
      if (!entry.isExpired(ttl: cacheTtl, now: _clock())) {
        return entry.data;
      }
    }

    try {
      final json = await _service.getWeather(lat: latitude, lon: longitude);

      final weather = WeatherModel.fromJson(json);

      _weatherCache[key] = CachedWeatherEntry(
        data: weather,
        timestamp: _clock(),
      );

      return weather;
    } catch (_) {
      return WeatherModel.unavailable();
    }
  }

  Future<List<DailyForecastModel>> getForecast({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final key = _cacheKey(latitude, longitude);

    if (!forceRefresh && _forecastCache.containsKey(key)) {
      final entry = _forecastCache[key]!;
      if (!entry.isExpired(ttl: cacheTtl, now: _clock())) {
        return entry.data;
      }
    }

    try {
      final json = await _service.getForecast(lat: latitude, lon: longitude);

      final forecast = DailyForecastModel.parseForecastList(
        json as Map<String, dynamic>,
      );

      _forecastCache[key] = CachedWeatherEntry(
        data: forecast,
        timestamp: _clock(),
      );

      return forecast;
    } catch (_) {
      rethrow;
    }
  }

  void clearCache() {
    _weatherCache.clear();
    _forecastCache.clear();
  }

  bool isWeatherCached(double lat, double lon) {
    final key = _cacheKey(lat, lon);
    final entry = _weatherCache[key];
    if (entry == null) return false;
    return !entry.isExpired(ttl: cacheTtl, now: _clock());
  }

  bool isForecastCached(double lat, double lon) {
    final key = _cacheKey(lat, lon);
    final entry = _forecastCache[key];
    if (entry == null) return false;
    return !entry.isExpired(ttl: cacheTtl, now: _clock());
  }
}
