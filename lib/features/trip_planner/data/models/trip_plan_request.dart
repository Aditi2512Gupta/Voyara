class TripPlanRequest {
  final String destination;
  final double latitude;
  final double longitude;
  final DateTime startDate;
  final int days;
  final double budget;
  final int travelers;
  final List<String> interests;

  const TripPlanRequest({
    required this.destination,
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.days,
    required this.budget,
    required this.travelers,
    required this.interests,
  });
}