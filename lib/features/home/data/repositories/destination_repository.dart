import 'package:voyara/core/services/local_dataset_service.dart';

class DestinationRepository {
  final LocalDatasetService localDatasetService;

  DestinationRepository(this.localDatasetService);

  Future<List<dynamic>> fetchDestinations() async {
    return await localDatasetService.loadDestinations();
  }

  Future<List<dynamic>> searchImages(String place) async {
    final destinations = await localDatasetService.loadDestinations();

    return destinations.where((destination) {
      final name =
          (destination["name"] ?? "").toString().toLowerCase();

      return name.contains(place.toLowerCase());
    }).toList();
  }
}