import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';

class GeoapifyService {
  GeoapifyService(this.apiService);

  final ApiService apiService;

  Future<dynamic> searchPlaces(String query) {
    return apiService.get(
      'https://api.geoapify.com/v1/geocode/search'
      '?text=$query'
      '&limit=20'
      '&apiKey=${ApiConstants.geoapifyApiKey}',
    );
  }

  Future<dynamic> reverseGeocode({
    required double lat,
    required double lon,
  }) {
    return apiService.get(
      'https://api.geoapify.com/v1/geocode/reverse'
      '?lat=$lat'
      '&lon=$lon'
      '&apiKey=${ApiConstants.geoapifyApiKey}',
    );
  }

  Future<dynamic> touristPlaces({
    required String filter,
    int limit = 30,
  }) {
    return apiService.get(
      '${ApiConstants.geoapifyBaseUrl}/places'
      '?categories='
      'tourism.attraction,'
      'tourism.sights,'
      'heritage,'
      'natural,'
      'national_park'
      '&filter=$filter'
      '&limit=$limit'
      '&apiKey=${ApiConstants.geoapifyApiKey}',
    );
  }
}