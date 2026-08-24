class GeoapifyPlaceModel {
  final String id;
  final String name;
  final String state;
  final String city;
  final String country;
  final String formatted;
  final double latitude;
  final double longitude;
  final String category;
  final double? distance;
  final String? imageUrl;
  final String wikipedia;
  final List<String> rawCategories;

  const GeoapifyPlaceModel({
    required this.id,
    required this.name,
    required this.state,
    required this.city,
    required this.country,
    required this.formatted,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.distance,
    this.imageUrl,
    this.wikipedia = '',
    required this.rawCategories,
  });

  factory GeoapifyPlaceModel.fromJson(Map<String, dynamic> json) {
    return GeoapifyPlaceModel(
      id: json['place_id']?.toString() ?? '',
      name: (json['name']?.toString().trim().isNotEmpty ?? false)
          ? json['name']
          : (json['address_line1']?.toString().trim().isNotEmpty ?? false)
          ? json['address_line1']
          : (json['formatted']?.toString().split(',').first ?? 'Unknown Place'),
      country: json['country'] ?? '',
      city: json['city'] ?? json['county'] ?? '',
      state: json['state'] ?? '',
      formatted: json['formatted'] ?? '',
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      category:
          json['categories'] is List && (json['categories'] as List).isNotEmpty
          ? json['categories'].first
                 .toString()
                 .split('.')
                 .last
                 .replaceAll('_', ' ')
          : 'Attraction',
      distance: (json['distance'] as num?)?.toDouble(),
      imageUrl: json['wiki_and_media']?['image']?.toString() ?? json['image']?.toString(),
      wikipedia: json['wiki_and_media']?['wikipedia']?.toString() ?? '',
      rawCategories: json['categories'] is List
          ? List<String>.from(json['categories'])
          : <String>[],
    );
  }
}
