import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherRepository {
  WeatherRepository(this._service);

  final WeatherService _service;

  final Map<String, WeatherModel> _weatherCache = {};

  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final key =
        "${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}";

    if (_weatherCache.containsKey(key)) {
      return _weatherCache[key]!;
    }

    try {
      final json = await _service.getWeather(
        lat: latitude,
        lon: longitude,
      );

      final weather = WeatherModel.fromJson(json);

      _weatherCache[key] = weather;

      return weather;
    } catch (_) {
      return WeatherModel.unavailable();
    }
  }
}