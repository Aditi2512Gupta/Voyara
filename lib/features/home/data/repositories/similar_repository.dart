import '../models/destination_model.dart';
import 'geoapify_repository.dart';

class SimilarRepository {
  const SimilarRepository(this._geoapifyRepository);

  final GeoapifyRepository _geoapifyRepository;

  Future<List<DestinationModel>> getSimilar({
    required DestinationModel destination,
  }) async {
    final places = await _geoapifyRepository.nearbyTouristPlaces(
      lat: destination.latitude,
      lon: destination.longitude,
      radius: 50000,
    );

    final used = <String>{};

    return places
        .where((p) => p.id != destination.id)
        .where((p) => used.add(p.id))
        .map((p) => DestinationModel.fromGeoapify(p, destination.latitude, destination.longitude))
        .take(8)
        .toList();
  }
}