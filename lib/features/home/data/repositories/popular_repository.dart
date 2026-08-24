import '../models/destination_model.dart';
import 'geoapify_repository.dart';

class PopularRepository {
  const PopularRepository(this._geoapifyRepository);

  final GeoapifyRepository _geoapifyRepository;

  Future<List<DestinationModel>> getPopular({
    required String country,
    required Set<String> excludedIds,
  }) async {
    final places = await _geoapifyRepository.searchTourismInCountry(country);

    final unique = <String>{};

    return places
        .where((p) => unique.add(p.id))
        .where((p) => !excludedIds.contains(p.id))
        .map(DestinationModel.fromGeoapify)
        .take(20)
        .toList();
  }
}