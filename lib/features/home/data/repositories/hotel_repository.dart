import '../models/hotel_model.dart';
import '../services/hotel_service.dart';

class HotelRepository {
  HotelRepository(this.service);

  final HotelService service;

  Future<List<HotelModel>> getHotels({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = await service.getHotels(
        latitude: latitude,
        longitude: longitude,
      );

      final features = data['features'] as List;

      return features
          .map(
            (e) => HotelModel.fromJson(
              e['properties'],
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}