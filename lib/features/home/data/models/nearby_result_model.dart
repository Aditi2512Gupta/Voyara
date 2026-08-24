import 'destination_model.dart';

class NearbyResultModel {
  final List<DestinationModel> destinations;
  final int usedRadius;

  const NearbyResultModel({
    required this.destinations,
    required this.usedRadius,
  });
}