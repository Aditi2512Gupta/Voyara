class TripAIContext {
  const TripAIContext({
    required this.destination,
    required this.latitude,
    required this.longitude,
    required this.weather,
    required this.description,
    required this.hotels,
    required this.attractions,
  });

  final String destination;

  final double latitude;

  final double longitude;

  final String weather;

  final String description;

  final List<String> hotels;

  final List<String> attractions;
}