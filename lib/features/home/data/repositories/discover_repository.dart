import '../models/destination_model.dart';
import '../models/geoapify_place_model.dart';
import 'geoapify_repository.dart';

class DiscoverRepository {
  const DiscoverRepository(this._geoapifyRepository);

  final GeoapifyRepository _geoapifyRepository;

  Future<List<DestinationModel>> search(String query) async {
    final places = await _geoapifyRepository.searchPlaces(query);

    return places.map(DestinationModel.fromGeoapify).toList();
  }

  Future<List<DestinationModel>> discover({
    required double latitude,
    required double longitude,
    required Set<String> excludedIds,
    required int startRadius,
  }) async {
    const allRadii = [
      10000,
      20000,
      50000,
      100000,
      200000,
      300000,
      500000,
      700000,
      1000000,
      1500000,
      2000000,
    ];

    List<GeoapifyPlaceModel> places = [];
    final radii = allRadii.where((r) => r > startRadius).toList();

    for (final radius in radii) {
      final result = await _geoapifyRepository.nearbyTouristPlaces(
        lat: latitude,
        lon: longitude,
        radius: radius,
      );

      places.addAll(result);

      final ids = places.map((e) => e.id).toSet();

      if (ids.length >= 25) {
        break;
      }
    }

    places.sort(
      (a, b) => (a.distance ?? double.infinity).compareTo(
        b.distance ?? double.infinity,
      ),
    );

    final unique = <String>{};

    return places
        .where((p) => unique.add(p.id))
        .where((p) => !excludedIds.contains(p.id))
        .map((p) => DestinationModel.fromGeoapify(p, latitude, longitude))
        .take(15)
        .toList();
  }
}
