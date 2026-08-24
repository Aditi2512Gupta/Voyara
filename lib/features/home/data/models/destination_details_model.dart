import 'destination_model.dart';
import 'weather_model.dart';

class DestinationDetailsModel {
  final DestinationModel destination;
  final String description;
  final WeatherModel? weather;
  final List<String> images;

  const DestinationDetailsModel({
    required this.destination,
    required this.description,
    required this.weather,
    required this.images,
  });
}