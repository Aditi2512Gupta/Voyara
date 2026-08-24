import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';

class WeatherService {
  WeatherService(this.apiService);

  final ApiService apiService;

  Future<dynamic> getWeather({
    required double lat,
    required double lon,
  }) {
    return apiService.get(
      '${ApiConstants.weatherBaseUrl}/weather'
      '?lat=$lat'
      '&lon=$lon'
      '&appid=${ApiConstants.weatherApiKey}'
      '&units=metric',
    );
  }
}