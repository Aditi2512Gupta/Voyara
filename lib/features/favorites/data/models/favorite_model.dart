class FavoriteModel {
  const FavoriteModel({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final double latitude;
  final double longitude;

  factory FavoriteModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return FavoriteModel(
      id: id,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}