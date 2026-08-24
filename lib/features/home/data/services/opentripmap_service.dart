import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';

class OpenTripMapService {
  OpenTripMapService(this.apiService);

  final ApiService apiService;

  Future<dynamic> fetchRadiusPlaces({
    required double lat,
    required double lon,
    required int radius,
  }) {
    return apiService.get(
      '${ApiConstants.openTripMapBaseUrl}/radius'
      '?radius=$radius'
      '&lon=$lon'
      '&lat=$lat'
      '&rate=3'
      '&format=json'
      '&limit=100'
      '&apikey=${ApiConstants.openTripMapApiKey}',
    );
  }

  Future<dynamic> fetchPlaceDetails(String xid) {
    return apiService.get(
      '${ApiConstants.openTripMapBaseUrl}/xid/$xid'
      '?apikey=${ApiConstants.openTripMapApiKey}',
    );
  }

  Future<List<dynamic>> fetchInterestingPlaces({
    required double lat,
    required double lon,
    required int radius,
  }) async {
    final data = await apiService.get(
      '${ApiConstants.openTripMapBaseUrl}/radius'
      '?radius=$radius'
      '&lon=$lon'
      '&lat=$lat'
      '&kinds='
      'interesting_places,architecture,historic,museums,'
      'natural,castles,religion,cultural'
      '&format=json'
      '&limit=100'
      '&apikey=${ApiConstants.openTripMapApiKey}',
    );

    return data as List<dynamic>;
  }
}