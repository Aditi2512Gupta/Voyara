import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';

class HotelService {
  HotelService(this.apiService);

  final ApiService apiService;

  Future<dynamic> getHotels({
    required double latitude,
    required double longitude,
  }) {
    return apiService.get(
      '${ApiConstants.geoapifyBaseUrl}/places'
      '?categories=accommodation.hotel'
      '&filter=circle:$longitude,$latitude,5000'
      '&limit=15'
      '&apiKey=${ApiConstants.geoapifyApiKey}',
    );
  }
}