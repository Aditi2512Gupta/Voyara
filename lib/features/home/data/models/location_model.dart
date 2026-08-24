class LocationModel {
  final String city;
  final String state;
  final String country;
  final String countryCode;

  const LocationModel({
    required this.city,
    required this.state,
    required this.country,
    this.countryCode = '',
  });

  String get fullAddress =>
      [city, state, country]
          .where((e) => e.isNotEmpty)
          .join(", ");
}

