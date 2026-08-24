import 'destination_model.dart';

class HomeDataModel {
  final List<DestinationModel> nearby;
  final List<DestinationModel> weekendGetaways;
  final List<DestinationModel> exploreBeyond;
  final List<DestinationModel> popular;

  // Actual radius used to fill Nearby.
  final int nearbyRadius;

  const HomeDataModel({
    required this.nearby,
    required this.weekendGetaways,
    required this.exploreBeyond,
    required this.popular,
    required this.nearbyRadius,
  });

  List<DestinationModel> get destinations => [
        ...nearby,
        ...weekendGetaways,
        ...exploreBeyond,
        ...popular,
      ];
}