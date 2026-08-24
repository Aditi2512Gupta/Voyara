import '../../../../core/services/api_service.dart';

class WikipediaService {
  WikipediaService(this.apiService);

  final ApiService apiService;

  Future<dynamic> getSummary(String place) {
    final cleanPlace = place.trim().replaceAll(' ', '_');
    return apiService.get(
      'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(cleanPlace)}',
    );
  }
}