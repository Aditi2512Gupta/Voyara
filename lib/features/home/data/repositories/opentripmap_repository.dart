import '../models/attraction_model.dart';
import '../services/opentripmap_service.dart';

class OpenTripMapRepository {
  OpenTripMapRepository(this.service);

  final OpenTripMapService service;

  Future<List<AttractionModel>> nearbyPlaces({
    required double lat,
    required double lon,
    int radius = 50000,
  }) async {
    final data = await service.fetchInterestingPlaces(
      lat: lat,
      lon: lon,
      radius: radius,
    );

    return data
        .where(
          (e) =>
              e is Map<String, dynamic> &&
              e['name'] != null &&
              e['name'].toString().trim().isNotEmpty,
        )
        .map((e) => AttractionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<dynamic> placeDetails(String xid) {
    return service.fetchPlaceDetails(xid);
  }
}