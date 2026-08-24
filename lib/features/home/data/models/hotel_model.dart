class HotelModel {
  const HotelModel({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.phone,
    this.website,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final String? phone;
  final String? website;

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      name: json['name'] ?? 'Unnamed Hotel',
      address: json['formatted'] ?? '',
      latitude: (json['lat'] as num?)?.toDouble() ?? 0,
      longitude: (json['lon'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      phone: json['contact']?['phone'],
      website: json['website'],
    );
  }
}
